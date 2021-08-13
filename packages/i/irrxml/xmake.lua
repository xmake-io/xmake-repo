package("irrxml")

    set_homepage("https://sourceforge.net/projects/irrlicht/")
    set_description("High speed and easy-to-use XML Parser for C++")

    set_urls("https://sourceforge.net/projects/irrlicht/files/irrXML%20SDK/$(version)/irrxml-$(version).zip")
    add_versions("1.2", "9b4f80639b2dee3caddbf75862389de684747df27bea7d25f96c7330606d7079")

    on_install(function (package)
        io.writefile("xmake.lua", [[
        add_rules("mode.debug", "mode.release")
        target("irrxml")
            set_kind("static")
            add_headerfiles("src/*.h")
            add_files("src/*.cpp")
        ]])

        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("irr::io::createIrrXMLReader(\"example.xml\")", {includes = "irrXML.h"}))
    end)
