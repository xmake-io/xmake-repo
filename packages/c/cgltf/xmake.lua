package("cgltf")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/jkuhlmann/cgltf")
    set_description("Single-file glTF 2.0 loader and writer written in C99")
    set_license("MIT")

    add_urls("https://github.com/jkuhlmann/cgltf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jkuhlmann/cgltf.git")
    add_versions("v1.13", "053d5320097334767486c6e33d01dd1b1c6224eac82aac2d720f4ec456d8c50b")

    on_install(function (package)
        os.cp("cgltf.h", package:installdir("include"))
        os.cp("cgltf_write.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #define CGLTF_IMPLEMENTATION
            #include <cgltf.h>
            void main() {
                cgltf_node node{};
                cgltf_float matrix[16];
                cgltf_node_transform_local(&node, matrix);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
