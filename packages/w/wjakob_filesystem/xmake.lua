package("wjakob_filesystem")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/wjakob/filesystem")
    set_description("A tiny self-contained path manipulation library for C++")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/wjakob/filesystem.git")
    add_versions("2021.10.28", "c5f9de30142453eb3c6fe991e82dfc2583373116")

    on_install(function (package)
        os.cp("filesystem", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <filesystem/path.h>
            void test() {
                filesystem::path path1{"dir1"};
                filesystem::path path2{"dir2"};
                auto path3 = path1 / path2;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
