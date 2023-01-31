package("meshoptimizer")

    set_homepage("https://github.com/zeux/meshoptimizer")
    set_description("Mesh optimization library that makes meshes smaller and faster to render")
    set_license("MIT")

    add_urls("https://github.com/zeux/meshoptimizer/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zeux/meshoptimizer.git")
    add_versions("v0.18", "f5bc07d7322e6292fe0afce03462b5c394d111386236f926fdc44d2aff3b854b")

    add_deps("cmake")
    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "MESHOPTIMIZER_API=__declspec(dllimport)")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DMESHOPT_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            struct Vertex
            {
                float px, py, pz;
                float nx, ny, nz;
                float tx, ty;
            };
            void test() {
                size_t total_indices = 0;
                std::vector<Vertex> vertices(total_indices);
                std::vector<unsigned int> remap(total_indices);
                size_t total_vertices = meshopt_generateVertexRemap(&remap[0], NULL, total_indices, &vertices[0], total_indices, sizeof(Vertex));
            }
        ]]}, {configs = {language = "cxx11"}, includes = "meshoptimizer.h"}))
    end)
