package("csvparser")
    set_kind("library", { headeronly = true })
    set_homepage("https://github.com/vincentlaucsb/csv-parser")
    set_description("A modern C++ library for reading, writing, and analyzing CSV (and similar) files (by vincentlaucsb)")
    set_license("MIT")

    add_urls("https://github.com/vincentlaucsb/csv-parser/archive/refs/tags/$(version).zip")
    add_versions("2.4.2", "7f23f4007349f76ba2d4c87ed50de354838ce67f927e141127386bc0a2ffee45")
    add_versions("2.3.0", "17eb8e1a4f2f8cdc6679329e4626de608bb33a830d5614184a21b5d8838bbbb0")
    add_versions("2.2.3", "83170169f2af38b171d7c3e127d9411fe381988a4b8910465f7d1c4c6169e815")
    add_versions("2.2.2", "e8fb8693680f2a0931ef28cb67a1ea007123201c74073fc588c18f5151e29cfd")
    add_versions("2.2.1", "96fd6a468f56fc157a11fcbc5cece6da952b06190837c46465d091eff674a813")
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
