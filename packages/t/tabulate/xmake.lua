package("tabulate")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/p-ranav/tabulate")
    set_description("Header-only library for printing aligned, formatted and colorized tables in Modern C++")
    set_license("MIT")

    add_urls("https://github.com/p-ranav/tabulate/archive/refs/tags/v$(version).zip",
             "https://github.com/p-ranav/tabulate.git")
    add_versions("1.4", "77aca3b371316fb33b8a794906614bc2ef0964ca23ba096161f5e2fade181ffb")

    on_install(function (package)
        os.cp("include/tabulate/asciidoc_exporter.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/cell.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/color.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/column.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/column_format.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/exporter.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/font_align.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/font_style.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/format.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/latex_exporter.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/markdown_exporter.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/optional_lite.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/printer.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/row.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/table.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/table_internal.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/tabulate.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/termcolor.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/utf8.hpp", package:installdir("include/tabulate"))
        os.cp("include/tabulate/variant_lite.hpp", package:installdir("include/tabulate"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[                    
            void test() {
                tabulate::Table test{};
            }
        ]]}, {configs = {languages = "c++11"}, includes = "tabulate/table.hpp"}))
    end)