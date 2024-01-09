package("strings_h")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/win32ports/strings_h")
    set_description("header-only Windows implementation of the <strings.h> header")
    set_license("MIT")

    add_urls("https://github.com/win32ports/strings_h.git")
    add_versions("2023.03.17", "822de6e8c368abb986b403792082189f3c602c45")

    on_install("windows", function (package)
        os.cp("strings.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <strings.h>
                    
            void test() {
                char buffer[6];
                bcopy("hello", buffer, 5);
            }
        ]]}))
    end)
