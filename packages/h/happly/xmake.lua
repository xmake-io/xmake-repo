package("happly")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/nmwsharp/happly")
    set_description("A C++ header-only parser for the PLY file format.")
    set_license("MIT")

    add_urls("https://github.com/nmwsharp/happly.git")
    add_versions("2022.01.07", "cfa2611550bc7da65855a78af0574b65deb81766")

    on_install(function (package)
        os.cp("happly.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                happly::PLYData plyIn("my_file.ply");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "happly.h"}))
    end)
