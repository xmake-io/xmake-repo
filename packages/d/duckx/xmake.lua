package("duckx")
    set_homepage("https://github.com/amiremohamadi/DuckX")
    set_description("C++ library for creating and modifying Microsoft Word (.docx) files")
    set_license("MIT")

    add_urls("https://github.com/amiremohamadi/DuckX.git")
    add_versions("2021.08.05", "6b6656309d7a46a483267abd1d591ef41226badd")

    add_deps("kuba-zip", "pugixml")

    on_install("windows", "linux", "macosx", "mingw", function (package)
        io.writefile("xmake.lua", [[
            add_requires("kuba-zip", "pugixml")
            add_rules("mode.debug", "mode.release")
            set_languages("c++11")
            target("duckx")
                set_kind("$(kind)")
                add_files("src/duckx.cpp")
                add_includedirs("include")
                add_headerfiles("include/*.hpp", {prefixdir = "duckx"})
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
                add_packages("kuba-zip", "pugixml")
        ]])
        io.replace("include/duckx.hpp", "zip.h", "zip/zip.h", {plain = true})
        io.replace("include/duckx.hpp", "<constants.hpp>", [["constants.hpp"]], {plain = true})
        io.replace("include/duckx.hpp", "<duckxiterator.hpp>", [["duckxiterator.hpp"]], {plain = true})
        io.replace("src/duckx.cpp", "zip_total_entries", "zip_entries_total", {plain = true})
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <duckx/duckx.hpp>
            void test() {
                duckx::Document doc("file.docx");
                doc.open();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
