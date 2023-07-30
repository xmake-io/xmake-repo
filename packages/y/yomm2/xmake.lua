package("yomm2")
    set_homepage("https://github.com/jll63/yomm2")
    set_description("Fast, orthogonal, open multi-methods. Solve the Expression Problem in C++17.")
    set_license("BSL-1.0")

    add_urls("https://github.com/jll63/yomm2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jll63/yomm2.git")

    add_versions("v1.4.0", "3f1f3a2b6fa5250405986b6cc4dff82299f866e2c6c2db75c7c3f38ecb91360f")

    add_deps("cmake", "boost")

    on_load(function (package)
        if not package:config("shared") then
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_install("windows", "linux", "macosx", "bsd", "mingw", "cross", function (package)
        local configs =
        {
            "-DYOMM2_ENABLE_TESTS=OFF",
            "-DYOMM2_ENABLE_EXAMPLES=OFF",
            "-DYOMM2_ENABLE_DOC=OFF",
            "-DYOMM2_ENABLE_BENCHMARKS=OFF",
            "-DYOMM2_ENABLE_TRACE=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DYOMM2_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DYOMM2_DEBUG_MACROS=" .. (package:is_debug() and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <yorel/yomm2/keywords.hpp>
            void test() {
                yorel::yomm2::update();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
