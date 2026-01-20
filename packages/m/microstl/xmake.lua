package("microstl")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/cry-inc/microstl")
    set_description("Small header-only C++ library for STL mesh files.")
    set_license("MIT")

    add_urls("https://github.com/cry-inc/microstl.git")
    add_versions("2023.02.04", "ec3868a14d8eff40f7945b39758edf623f609b6f")

    on_install(function (package)
        os.cp("include/microstl.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <filesystem>
            void test() {
                std::filesystem::path filePath("example.stl");
                microstl::MeshReaderHandler meshHandler;
                microstl::Result result = microstl::Reader::readStlFile(filePath, meshHandler);
                const microstl::Mesh& mesh = meshHandler.mesh;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "microstl.h"}))
    end)
