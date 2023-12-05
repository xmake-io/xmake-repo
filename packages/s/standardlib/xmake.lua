package("standardlib")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/gregoryc/standardlib")
    set_description("an actually usable and maximally efficient C standard library to make C as easy (or easier) than other languages")

    add_urls("https://github.com/gregoryc/standardlib.git")
    add_versions("2023.12.5", "4fb308a5716927e5622a0488d7aa104660c96841")

    on_install("linux", function (package)
        os.cp("standardlib.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "standardlib.h"
            #include <stdio.h>
            void test() {
                const char *text = "This is a sample text";
                const char *suffix = "text";
                printf("Does the string end with \"%s\"? %s\n", suffix, ends_with(text, suffix) ? "Yes" : "No");
            }
        ]]}))
    end)
