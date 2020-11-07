package("stackwalker")

    set_homepage("https://curl.haxx.se/")
    set_description("The multiprotocol file transfer library.")

    set_urls("https://github.com/JochenKalmbach/StackWalker/archive/$(version).zip",
             "https://github.com/JochenKalmbach/StackWalker.git")
    add_versions("1.20", "b139c83b7c4991930ebe48eae43b0feedca034e136f00be294f3641495b2c835")

    add_deps("cmake")
    add_syslinks("advapi32")

    on_install("windows", function (package)
        local configs = {"-DStackWalker_DISABLE_TESTS=ON"}
        import("package.tools.cmake").install(package, configs)
   end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "StackWalker.h"

            void Func5() { StackWalker sw; sw.ShowCallstack(); }
            void Func4() { Func5(); }
            void Func3() { Func4(); }
            void Func2() { Func3(); }
            void Func1() { Func2(); }

            int test()
            {
                Func1();
                return 0;
            }
        ]]}))
    end)
