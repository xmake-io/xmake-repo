package("tinygltf")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/syoyo/tinygltf/")
    set_description("Header only C++11 tiny glTF 2.0 library")
    set_license("MIT")

    add_urls("https://github.com/syoyo/tinygltf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/syoyo/tinygltf.git")
    add_versions("v2.5.0", "5d85bd556b60b1b69527189293cfa4902957d67fabb8582b6532f23a5ef27ec1")
    add_versions("v2.6.3", "f61e4a501baa7fbf31b18ea0f6815a59204ad0de281f7b04f0168f6bbd17c340")
    add_versions("v2.8.9", "cfff42b9246e1e24d36ec4ae94a22d5f4b0a1c63c796babb5c2a13fe66aed5e9")
    add_versions("v2.8.13", "72c3e5affa8389442582e4cf67426376e2dff418e998e19822260f4bf58b74b8")

    add_deps("cmake", "nlohmann_json", "stb")

    on_install(function (package)
        local configs = {
            "-DTINYGLTF_BUILD_LOADER_EXAMPLE=OFF",
            "-DTINYGLTF_HEADER_ONLY=ON"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                tinygltf::TinyGLTF loader;
            }
        ]]}, {configs = {languages = "c++14"}, includes = "tiny_gltf.h"}))
    end)
