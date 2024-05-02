package("csvparser")

    set_homepage("https://github.com/vincentlaucsb/csv-parser")
    set_description("A modern C++ library for reading, writing, and analyzing CSV (and similar) files (by vincentlaucsb)")

    add_urls("https://github.com/vincentlaucsb/csv-parser/archive/refs/tags/$(version).zip")
    add_versions("2.2.0", "b7744b28f3ac5f92c17379f323733cb8872ea48ef2347842604dc54285d60640")
    add_versions("2.1.1", "5fb6fc1c32196fb8cda144f192964b5bbedf61da9015d6c0edb8cb39b0dacff8")

    on_install(function (package)
        os.cp("single_include/csv.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace csv;
            void test(int argc, char** argv) {
                CSVReader reader("example.csv");
                for (CSVRow& row: reader) {
                    for (CSVField& field: row) {
                    }
                }
            }
        ]]}, {includes = "csv.hpp", configs = {languages = "cxx17"}}))
    end)