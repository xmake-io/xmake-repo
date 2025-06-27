package("standardlib")
    set_kind("library", {headeronly = true})    
    set_homepage("https://github.com/gregoryc/standardlib")
    set_description("A complete standardlib for c for once")

    add_urls("https://github.com/gregoryc/standardlib.git")
    add_versions("2024.03.25", "d27a1293ccfe7ef04a961806754c5d1272614b72")
    add_versions("2023.12.5", "4fb308a5716927e5622a0488d7aa104660c96841")

    on_install(function (package)
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
