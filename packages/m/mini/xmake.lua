package("mini")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/metayeti/mINI")
    set_description("INI file reader and writer")
    set_license("MIT")

    add_urls("https://github.com/metayeti/mINI/archive/refs/tags/$(version).tar.gz",
             "https://github.com/metayeti/mINI.git")

    add_versions("0.9.17", "2b5a5772a01691269d13c259590c5e5cff0334d1131778bc93408d6757a63be0")
    add_versions("0.9.16", "ce20e12b1e3bcd79d6eaa47bf8d4bb319e843dfa3585e069e73d581bdf0a81ec")
    add_versions("0.9.15", "241e105ab074827ab8b40582aa7b04c6191f84b244603969965c0874ad4f942c")

    on_install(function (package)
        os.cp("src/mini", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                mINI::INIFile file("myfile.ini");
            }
        ]]}, {configs = {languages = "c++17"}, includes = "mini/ini.h"}))
    end)
