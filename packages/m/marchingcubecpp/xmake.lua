package("marchingcubecpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/aparis69/marchingcubecpp")
    set_description("A public domain/MIT header-only marching cube implementation in C++ without anything fancy.")
    set_license("MIT")

    add_urls("https://github.com/aparis69/marchingcubecpp.git")

    add_versions("2023.09.12", "f03a1b3ec29b1d7d865691ca8aea4f1eb2c2873d")

    on_install(function (package)
        io.replace("MC.h", "#include <cmath>", "#include <cmath>\n#include <cstdint>", {plain = true})
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                // First compute a scalar field
                const int n = 100;
                MC::MC_FLOAT* field = new MC::MC_FLOAT[n * n * n];
                // [...]
                
                // Compute isosurface using marching cube
                MC::mcMesh mesh;
                MC::marching_cube(field, n, n, n, mesh);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "MC.h"}))
    end)
