package("fx-gltf")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/jessey-git/fx-gltf")
    set_description("A C++14/C++17 header-only library for simple, efficient, and robust serialization/deserialization of glTF 2.0")
    set_license("MIT")

    add_urls("https://github.com/jessey-git/fx-gltf/archive/refs/tags/$(version).tar.gz")
    add_urls("https://github.com/jessey-git/fx-gltf.git")

    add_versions("v1.2.0", "d8eaceba72ea6574b982c7b0d2328fd3f8ad519db4a37cf63cd3f8020d7722bf")
    add_versions("v2.0.0", "d044d191f9f6c956bdbaf548d960ae9831fd13dfdc4c82fceefa90cb02a68091")

    add_deps("nlohmann_json")

    on_install(function(pkg)
        os.cp("include/fx/gltf.h", pkg:installdir("include", "fx"))
    end)

    on_test(function(pkg)
        assert(pkg:check_cxxsnippets({test = [[
            void test() {
                fx::gltf::Document doc;
            }
        ]]}, {configs = {languages = {"c++14", "c++17"}}, includes = "fx/gltf.h"}))
    end)
