package("simpleini")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/brofield/simpleini")
    set_description("Cross-platform C++ library providing a simple API to read and write INI-style configuration files.")
    set_license("MIT")

    set_urls("https://github.com/brofield/simpleini/archive/refs/tags/$(version).tar.gz",
             "https://github.com/brofield/simpleini.git")
    add_versions("v4.25", "10001ee1486ae55259a5408786262bc0f72d699bc9637d536ebc62765d3ecd3b")
    add_versions("v4.22", "b3a4b8f9e03aabd491aa55fd57457115857b9b9c7ecf4abf7ff035ca9d026eb8")
    add_versions("v4.19", "dc10df3fa363be2c57627d52cbb1b5ddd0689d474bf13908e822c1522df8377e")

    add_configs("convert", {description = "Unicode converter to use.", type = "string", values = {"none", "generic", "icu", "win32"}})

    on_load(function (package)
        if package:config("convert") == nil then
            if package:is_plat("windows") then
                package:config_set("convert", "win32")
            else
                package:config_set("convert", "generic")
            end
        end
        if package:config("convert") == "none" then
            package:add("defines", "SI_NO_CONVERSION")
        elseif package:config("convert") == "generic" then
            package:add("defines", "SI_CONVERT_GENERIC")
            package:add("deps", "convertutf")
        elseif package:config("convert") == "icu" then
            package:add("defines", "SI_CONVERT_ICU")
            package:add("deps", "icu4c")
        elseif package:config("convert") == "win32" then
            package:add("defines", "SI_CONVERT_WIN32")
        end
    end)

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
