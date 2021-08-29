package("docopt")

    set_homepage("https://github.com/docopt/docopt.cpp")
    set_description("Pythonic command line arguments parser (C++11 port)")
    set_license("BSL-1.0")

    add_urls("https://github.com/docopt/docopt.cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/docopt/docopt.cpp.git")
    add_versions("v0.6.3", "28af5a0c482c6d508d22b14d588a3b0bd9ff97135f99c2814a5aa3cbff1d6632")

    add_deps("cmake")
    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "DOCOPT_DLL")
        end
    end)

    on_install(function (package)
        local rmtarget = package:config("shared") and "docopt_s" or "docopt"
        io.replace("CMakeLists.txt", "install(TARGETS " .. rmtarget .. " EXPORT", "#", {plain = true})
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            static const char USAGE[] =
R"(Naval Fate.

    Usage:
      naval_fate (-h | --help)
      naval_fate --version

    Options:
      -h --help     Show this screen.
      --version     Show version.
)";

            void test(int argc, char *argv[]) {
                std::map<std::string, docopt::value> args
                    = docopt::docopt(USAGE, { argv + 1, argv + argc }, true, "Naval Fate 2.0");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "docopt/docopt.h"}))
    end)
