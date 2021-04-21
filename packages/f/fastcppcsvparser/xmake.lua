package("fastcppcsvparser")

    set_homepage("https://github.com/ben-strasser/fast-cpp-csv-parser")
    set_description("This is a small, easy-to-use and fast header-only library for reading comma separated value (CSV) files (by ben-strasser)")

    add_urls("https://github.com/ben-strasser/fast-cpp-csv-parser.git")
    add_versions("2021.01.03", "75600d0b77448e6c410893830df0aec1dbacf8e3")

    on_install(function (package)
        if package:is_plat("macosx", "iphoneos") then
            io.replace("csv.h", "noexcept", "_NOEXCEPT")
        end
        os.cp("csv.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                io::CSVReader<3> in("example.csv");
                in.read_header(io::ignore_extra_column, "vendor", "size", "speed");
                std::string vendor; int size; double speed;
                while(in.read_row(vendor, size, speed));
            }
        ]]}, {includes = "csv.h", configs = {languages = "cxx11"}}))
    end)