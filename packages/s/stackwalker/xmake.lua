package("stackwalker")

    set_homepage("https://github.com/JochenKalmbach/StackWalker")
    set_description("A library to walk the callstack in windows applications.")
    set_license("BSD-2-Clause")

    set_urls("https://github.com/JochenKalmbach/StackWalker/archive/$(version).zip",
             "https://github.com/JochenKalmbach/StackWalker.git")

    add_versions("1.20", "b139c83b7c4991930ebe48eae43b0feedca034e136f00be294f3641495b2c835")
    add_patches("1.20", path.join(os.scriptdir(), "patches", "1.20", "debug_build.patch"), "dcd455d9c3560bcc7793e7c2f0ffafd363f26754ae87091fb982fffcff298466")

    add_deps("cmake")

    if is_plat("windows") then
        add_syslinks("advapi32")
    end

    on_install("windows", function (package)
        local configs = {"-DStackWalker_DISABLE_TESTS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
   end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void Func5() { StackWalker sw; sw.ShowCallstack(); }
            void Func4() { Func5(); }
            void Func3() { Func4(); }
            void Func2() { Func3(); }
            void Func1() { Func2(); }

            void test() {
                Func1();
            }
        ]]}, {includes = {"StackWalker.h"}}))
    end)
