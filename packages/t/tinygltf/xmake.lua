package("tinygltf")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/syoyo/tinygltf/")
    set_description("Header only C++11 tiny glTF 2.0 library")
    set_license("MIT")

    add_urls("https://github.com/syoyo/tinygltf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/syoyo/tinygltf.git")
    add_versions("v2.5.0", "5d85bd556b60b1b69527189293cfa4902957d67fabb8582b6532f23a5ef27ec1")
    add_versions("v2.6.3", "f61e4a501baa7fbf31b18ea0f6815a59204ad0de281f7b04f0168f6bbd17c340")

    add_deps("stb", "nlohmann_json")
    on_install(function (package)
        os.cp("tiny_gltf.h", package:installdir("include"))
        os.cp("cmake/TinyGLTFConfig.cmake", package:installdir("cmake"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                tinygltf::TinyGLTF loader;
            }
        ]]}, {configs = {languages = "c++14"}, includes = "tiny_gltf.h"}))
    end)
