package("cartographer")
    set_homepage("https://github.com/cartographer-project/cartographer")
    set_description("Cartographer is a system that provides real-time simultaneous localization and mapping (SLAM) in 2D and 3D across multiple platforms and sensor configurations.")
    set_license("Apache-2.0")

    add_urls("https://github.com/cartographer-project/cartographer/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cartographer-project/cartographer.git")

    add_versions("1.0.0", "474a410bf6457eb8a0fd92ea412d7889fb013051e625d3ee25e8d65e4113fd6c")
    add_versions("2.0.0", "abba0daa348095a5e821ee5e8037bad5d06f89f4c21ea850da5ab8a7e6997a2a")

    add_patches("1.0.0", path.join(os.scriptdir(), "patches", "1.0.0", "fix-build-error.patch"), "a4bb53d6f098c77a397d72c244d4283af1f9eec8a4ca7a7fa28de77b06d1201e")
    add_patches("1.0.0", path.join(os.scriptdir(), "patches", "1.0.0", "remove-boost.patch"), "bd0666bbf4eff2f4fda0c6bd55c960fd60af848f7d750a9c1efaffda2abc1e9b")
    add_patches("2.0.0", path.join(os.scriptdir(), "patches", "2.0.0", "fix-build-error.patch"), "5b59ffeb1ef339759e8def5c3a4e4793d5efc9d2af6feb782cae09afd3dd7a04")
    add_patches("2.0.0", path.join(os.scriptdir(), "patches", "2.0.0", "remove-boost.patch"), "9b323141681748e3191c9964c7774bbb5acf17292dda76554763da4999a6358e")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("zlib")
    add_deps("ceres-solver 2.1.0", {configs = {suitesparse = true}})
    add_deps("protobuf-cpp 3.19.4")
    add_deps("abseil", "cairo", "eigen", "lua")

    on_install("windows|x64", "windows|x86", "macosx|x86_64", "linux", function (package)
        for _, headerfile in ipairs(os.files("cartographer/**.h")) do
            io.replace(headerfile, "cairo/cairo.h", "cairo.h", {plain = true})
        end
        for _, file in ipairs(table.join(os.files("cartographer/**.cc"), os.files("cartographer/**.h"))) do
            io.replace(file, "LOCKS_EXCLUDED", "ABSL_LOCKS_EXCLUDED", {plain = true})
            io.replace(file, "GUARDED_BY", "ABSL_GUARDED_BY", {plain = true})
            io.replace(file, "EXCLUSIVE_LOCKS_REQUIRED", "ABSL_EXCLUSIVE_LOCKS_REQUIRED", {plain = true})
        end
        for _, protofile in ipairs(os.files("cartographer/**.proto")) do
            io.replace(protofile, [[import "cartographer/]], [[import "]], {plain = true})
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        io.replace("cartographer/common/configuration_file_resolver.cc", [[#include "cartographer/common/config.h"]], "", {plain = true})
        io.replace("cartographer/common/configuration_file_resolver.cc", [[configuration_files_directories_.push_back(kConfigurationFilesDirectory);]], "", {plain = true})
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "cartographer/mapping/proto/map_builder_options.pb.h"
            void test() {
                cartographer::mapping::proto::MapBuilderOptions map_builder_options;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
