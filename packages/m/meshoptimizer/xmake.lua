package("meshoptimizer")
    set_homepage("https://github.com/zeux/meshoptimizer")
    set_description("Mesh optimization library that makes meshes smaller and faster to render")
    set_license("MIT")

    add_urls("https://github.com/zeux/meshoptimizer/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zeux/meshoptimizer.git")

    add_versions("v1.0.1", "9579624541e27e1cd01379c87e1295407e72c49e4b5b3e2f948393f3b68258ac")
    add_versions("v1.0", "30d1c3651986b2074e847b17223a7269c9612ab7f148b944250f81214fed4993")
    add_versions("v0.25", "68b2fef4e4eaad98e00c657c1e7f8982a7176e61dd7efdeaec67a025b8519be9")
    add_versions("v0.24", "af5f6bc410e2df9f0f80dce1f1d77ff55f53dc08c17fdc07e58367b613c27603")
    add_versions("v0.23", "ac574107dd7e532ecfbea208fff9cd18fbcd1687f1d540ff8a798624ada453e0")
    add_versions("v0.22", "e296cf0685b6421f84bd8a44d0a3cca82a219500f11c793dfbb6087ec86bb1a3")
    add_versions("v0.18", "f5bc07d7322e6292fe0afce03462b5c394d111386236f926fdc44d2aff3b854b")
    add_versions("v0.20", "cf1077a83958bed3d8da28a841ca53a6a42d871e49023edce64e37002a0f5a48")
    add_versions("v0.21", "050a5438e4644833ff69f35110fcf4e37038a89c5fdc8aed45d8cd848ecb3a20")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "MESHOPTIMIZER_API=__declspec(dllimport)")
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
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
