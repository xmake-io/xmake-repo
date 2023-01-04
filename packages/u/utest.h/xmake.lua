package("utest.h")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.duskborn.com/utest_h/")
    set_description("single header unit testing framework for C and C++")

    add_urls("https://github.com/sheredom/utest.h.git")
    add_versions("2022.09.01", "d5d71b6623e23b3f860c996b31ec7bbfb0943119")

    on_install("windows", "linux", "bsd", "macosx", "mingw", "android", "iphoneos", "cross", function (package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include "utest.h"
            UTEST(foo, bar) {
              ASSERT_TRUE(1);
            }
        ]]}))
    end)
