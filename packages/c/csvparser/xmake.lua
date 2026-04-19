package("csvparser")
    set_kind("library", { headeronly = true })
    set_homepage("https://github.com/vincentlaucsb/csv-parser")
    set_description("A modern C++ library for reading, writing, and analyzing CSV (and similar) files (by vincentlaucsb)")
    set_license("MIT")

    add_urls("https://github.com/vincentlaucsb/csv-parser/archive/refs/tags/$(version).tar.gz",
             "https://github.com/vincentlaucsb/csv-parser.git")
    add_versions("3.1.0", "7820acdbc31657366fa394ce5341730f9ed600fcd737def6052ee711294d544a")
    add_versions("2.5.2", "b6ceb7c75a37f3539424bdc583b7424d78a55c1986b732dadbcce0738c212058")
    add_versions("2.4.2", "a185cbcd9dcaac584de852b6c4a39f6bed29872141379a5cd76c78d890d10325")
    add_versions("2.3.0", "27b8ac51aa58b9a4debd8ccfb44738c8583a2e874da42f56bbdf3764b75f3af5")
    add_versions("2.2.3", "e70ea75612fb45f9a9dd83145fb3fbf0b5929a32683de478ad429cdd85f10e4e")

    add_includedirs("include")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace csv;
            void test() {
                CSVReader reader("example.csv");
                for (CSVRow& row: reader) {
                    for (CSVField& field: row) {
                    }
                }
            }
        ]]}, {includes = "csv.hpp", configs = {languages = "c++17"}}))
    end)
