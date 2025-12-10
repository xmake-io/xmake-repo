package("trianglemeshdistance")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/InteractiveComputerGraphics/TriangleMeshDistance")
    set_description("Header only, single file, simple and efficient C++11 library to compute the signed distance function (SDF) to a triangle mesh")
    set_license("Apache-2.0")

    add_urls("https://github.com/InteractiveComputerGraphics/TriangleMeshDistance.git")

    add_versions("2025.12.06", "566c9486533082fe7d9a3ffae15799bc5c125528")

    add_deps("cmake")

    on_install(function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(tests)", "", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                std::vector<std::array<double, 3>> vertices;
                std::vector<std::array<int, 3>> triangles;

                // (... fill the `vertices` and `triangles` with the mesh data ...)

                // Initialize TriangleMeshDistance
                tmd::TriangleMeshDistance mesh_distance(vertices, triangles);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "tmd/TriangleMeshDistance.h"}))
    end)
