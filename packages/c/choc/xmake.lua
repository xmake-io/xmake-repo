package("choc")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Tracktion/choc")
    set_description("A collection of header only classes, permissively licensed, to provide basic useful tasks with the bare-minimum of dependencies.")
    set_license("ISC")

    add_urls("https://github.com/Tracktion/choc.git")
    add_versions("2025.01.27", "6dfac9fec70eae9159e64dc55538d40a2171175e")

    on_install(function (package)
        os.cp("*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <text/choc_StringUtilities.h>

            void test() {
               choc::text::isDigit('1');
            }
        ]]}, {configs = {languages = "cxx17"}}))
    end)
