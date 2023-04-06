package("simpleini")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/brofield/simpleini")
    set_description("Cross-platform C++ library providing a simple API to read and write INI-style configuration files.")
    set_license("MIT")

    set_urls("https://github.com/brofield/simpleini/archive/refs/tags/$(version).tar.gz",
             "https://github.com/brofield/simpleini.git")
    add_versions("v4.19", "dc10df3fa363be2c57627d52cbb1b5ddd0689d474bf13908e822c1522df8377e")

    add_deps("convertutf", {optional = true})

    on_install(function (package)
        os.cp("SimpleIni.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                CSimpleIniA ini;
                ini.SetUnicode();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "SimpleIni.h"}))
    end)
