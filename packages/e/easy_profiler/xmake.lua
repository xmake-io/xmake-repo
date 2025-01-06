package("easy_profiler")
    set_homepage("https://github.com/yse/easy_profiler")
    set_description("Lightweight profiler library for c++")
    set_license("MIT")

    add_urls("https://github.com/yse/easy_profiler/archive/refs/tags/$(version).tar.gz",
             "https://github.com/yse/easy_profiler.git")

    add_versions("v2.1.0", "fabf95d59ede9da4873aebd52ef8a762fa8578dcdbcc6d7cdd811b5a7c3367ad")

    add_deps("cmake")

    on_install("macosx", "linux", "windows", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            static void test() {
                EASY_FUNCTION();
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"easy/profiler.h"}}))
    end)
