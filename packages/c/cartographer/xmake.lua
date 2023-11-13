package("cartographer")
    set_homepage("https://github.com/cartographer-project/cartographer")
    set_description("Cartographer is a system that provides real-time simultaneous localization and mapping (SLAM) in 2D and 3D across multiple platforms and sensor configurations.")
    set_license("Apache-2.0")

    add_urls("https://github.com/cartographer-project/cartographer/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cartographer-project/cartographer.git")

    add_versions("1.0.0", "474a410bf6457eb8a0fd92ea412d7889fb013051e625d3ee25e8d65e4113fd6c")

    add_patches("1.0.0", path.join(os.scriptdir(), "patches", "1.0.0", "fix-build-error.patch"), "a4bb53d6f098c77a397d72c244d4283af1f9eec8a4ca7a7fa28de77b06d1201e")
    add_patches(">=1.0.0", path.join(os.scriptdir(), "patches", "1.0.0", "remove-config_h.patch"), "494c5d16dc36fd40f2145993aecf62c0a934bc86e228ca9bedc18291707829ac")
        
    add_deps("cmake")
    add_deps("boost", {configs = {shared = true, iostreams = true}})
    add_deps("ceres-solver", {configs = {suitesparse = true}})
    add_deps("abseil", "cairo", "eigen", "lua", "protobuf-cpp")

    on_install("windows|x64", "windows|x86", "macosx", "linux", function (package)
        for _, headerfile in ipairs(os.files("cartographer/**.h")) do
            io.replace(headerfile, "cairo/cairo.h", "cairo.h", {plain = true})
        end
        for _, protofile in ipairs(os.files("cartographer/**.proto")) do
            io.replace(protofile, [[import "cartographer/]], [[import "]], {plain = true})
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        if is_plat("windows") then
            package:add("defines", "NOMINMAX")
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cartographer/mapping/pose_graph.h>
            void test() {
                cartographer::mapping::PoseGraph pose_graph;
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
