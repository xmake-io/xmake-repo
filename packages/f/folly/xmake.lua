package("folly")

    set_homepage("https://github.com/facebook/folly")
    set_description("An open-source C++ library developed and used at Facebook.")
    set_license("Apache-2.0")

    add_urls("https://github.com/facebook/folly/releases/download/v$(version).00/folly-v$(version).00.zip",
             "https://github.com/facebook/folly.git")

    add_versions("2023.11.20", "7aabcfc5d85ca88fbd06bca1a7381654ec8b0c31fe919788b8d7c18ba50f38ff")
    add_versions("2024.02.26", "ed7086aa7a3e66e9afd2aeb1ddb746d94dcc0c80b792635cb72cd3622e2de9e3")
    add_versions("2024.03.04", "55fadd809f749b1834d20f1dff9aeb410f39b3e3025218d3b2e014948b58763d")
    add_versions("2024.03.11", "771f638669bdb514f0c66caff404d1df0e65868b65555405eb22a7c9298d3a7a")
    add_versions("2024.03.18", "037bd742b91e35e057d13bedcbdf55328e35805cf91f7bc1ca850a72ba974578")
    add_versions("2024.03.25", "3c57b0d1f1266e935aef1ed54535561fd2eeedc1aa946fbc46871e839014f74c")
    add_versions("2024.04.01", "f09e522c76a5f102c40c54726f6f255b0dc127c78f9c8c9ac117fc0f7ac284bb")
    add_versions("2024.06.10", "27d7f825a9a3469b59a4f0a5ba2edac733407ea8dcc036e7ca9279d803ece1e9")

    add_patches("<=2024.04.01", path.join(os.scriptdir(), "patches", "2023.11.20", "pkgconfig.patch"), "6838623d453418569853f62ad97c729e802a120c13d804aabba6d6455997e674")
    add_patches("<=2024.04.01", path.join(os.scriptdir(), "patches", "2023.11.20", "msvc.patch"), "1ee01c75528bd42736541022af461e44af3031c01d62c9342006f0abc0f44f2d")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("boost", {configs = {date_time = true, iostreams = true, context = true, filesystem = true, program_options = true, regex = true, system = true, thread = true}})
    add_deps("libevent", {configs = {openssl = true}})
    add_deps("double-conversion", "gflags", "glog <0.7.0", "zlib", "fmt")
    add_deps("bzip2", "lz4", "zstd", {optional = true})
    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load("linux", function (package)
        package:add("deps", "libaio")
        package:add("deps", "liburing")
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTS=OFF",
                         "-DCMAKE_DISABLE_FIND_PACKAGE_LibDwarf=ON",
                         "-DCMAKE_DISABLE_FIND_PACKAGE_Libiberty=ON",
                         "-DCMAKE_DISABLE_FIND_PACKAGE_LibURCU=ON",
                         "-DLIBURCU_FOUND=OFF",
                         "-DBOOST_LINK_STATIC=ON",
                         "-DCMAKE_CXX_STANDARD=17"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        if not package:is_plat("linux") then
            table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_LibAIO=ON")
            table.insert(configs, "-DLIBAIO_FOUND=OFF")
        end 
        import("package.tools.cmake").install(package, configs)
    end)

    on_test("windows", "macosx", function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cassert>
            void test() {
                folly::CpuId id;
                assert(folly::kIsArchAmd64 == id.mmx());
            }
        ]]}, {configs = {languages = "c++17"}, includes = "folly/CpuId.h"}))
    end)

    on_test("linux", function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "folly/experimental/io/IoUring.h"
            #include "folly/experimental/io/AsyncIO.h"
            void test() {
                folly::AsyncIOOp asyncIOOp;
                folly::IoUringOp ioUringOp;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
