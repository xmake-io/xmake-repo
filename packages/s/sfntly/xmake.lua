package("sfntly")

    set_homepage("https://github.com/googlefonts/sfntly")
    set_description("The sfntly project contains Java and C++ libraries for reading, editing, and writing sfnt container fonts (OpenType, TrueType, AAT/GX, and Graphite.)")

    local commits = {["20190917"] = "1e7adf313bd9c488a70015f8df8782f7c65e9ce7"}
    add_urls("https://github.com/googlefonts/sfntly/archive/$(version).zip", {version = function (version) return commits[version] end})
    add_versions("20190917", "8b27d570624dcbe1769c64274c75cfce4afc9d12893b0b8acba090e5c870e51f")

    add_deps("icu4c")
    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("linux", "macosx", "windows", function (package)
        os.cd(path.join("cpp", "src"))
        io.replace(path.join("sfntly", "port", "atomic.h"), "WIN32", "_WIN32")
        io.replace(path.join("sfntly", "port", "lock.h"), "WIN32", "_WIN32")
        io.writefile("xmake.lua", string.format([[
            add_rules("mode.debug", "mode.release")
            add_requires("icu4c")
            target("sfntly")
                set_kind("%s")
                set_languages("cxx14")
                add_includedirs("%s")
                add_packages("icu4c")
                add_defines("SFNTLY_NO_EXCEPTION")
                if is_plat("windows") then
                    add_defines("NOMINMAX")
                end
                add_files("sfntly/*.cc", "sfntly/data/*.cc", "sfntly/port/*.cc", "sfntly/table/*.cc", "sfntly/table/core/*.cc", "sfntly/table/bitmap/*.cc", "sfntly/table/truetype/*.cc")
                add_headerfiles("(sfntly/*.h)", "(sfntly/data/*.h)", "(sfntly/math/*.h)", "(sfntly/port/*.h)", "(sfntly/table/*.h)", "(sfntly/table/core/*.h)", "(sfntly/table/bitmap/*.h)", "(sfntly/table/truetype/*.h)")
        ]], package:config("shared") and "shared" or "static", os.curdir():replace("\\", "/")))
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                sfntly::FontArray fonts;
                sfntly::Ptr<sfntly::Font> font;
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"sfntly/font.h"}}))
    end)
