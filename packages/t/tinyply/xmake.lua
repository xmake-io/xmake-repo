package("tinyply")

    set_homepage("https://github.com/ddiakopoulos/tinyply")
    set_description("C++11 ply 3d mesh format importer & exporter")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/ddiakopoulos/tinyply/archive/$(version).tar.gz")
    add_urls("https://github.com/ddiakopoulos/tinyply.git")
    add_versions("2.3.4", "1bb1462727a363f7b77a10e51cd023095db7b281d2f201167620a83e495513c6")

    on_install("macosx", "linux", "windows", "mingw", "android", "iphoneos", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("tinyply")
                set_kind("$(kind)")
                set_languages("c++11")
                add_files("source/tinyply.cpp")
                add_headerfiles("source/tinyply.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                tinyply::PlyFile plyFile;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "tinyply.h"}))
    end)
