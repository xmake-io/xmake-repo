package("tinygltf")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/syoyo/tinygltf/")
    set_description("Header only C++11 tiny glTF 2.0 library")
    set_license("MIT")

    add_urls("https://github.com/syoyo/tinygltf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/syoyo/tinygltf.git")

    add_versions("v2.9.7", "9d31cf7f22e81febaf1ad587d7722582c154f7d9125673ee46c0c594765e8f35")
    add_versions("v2.9.6", "ba2c47a095136bfc8a5d085421e60eb8e8df3bca4ae36eb395084c1b264c6927")
    add_versions("v2.9.5", "7b93da27c524dd17179a0eeba6f432b0060d82f6222630ba027c219ce11e24db")
    add_versions("v2.9.3", "f5f282508609a0098048c8ff25d72f4ef0995bc1d46bc7a5d740e559d80023d2")
    add_versions("v2.9.2", "b34d1456bb1d63bbb4e05ea1e4d8691d0253a03ef72385a8bffd2fae4b743feb")
    add_versions("v2.8.22", "97c3eb1080c1657cd749d0b49af189c6a867d5af30689c48d5e19521e7b5a070")
    add_versions("v2.8.21", "e567257d7addde58b0a483832cbaa5dd8f15e5bcaee6f023831e215d1a2c0502")
    add_versions("v2.5.0", "5d85bd556b60b1b69527189293cfa4902957d67fabb8582b6532f23a5ef27ec1")
    add_versions("v2.6.3", "f61e4a501baa7fbf31b18ea0f6815a59204ad0de281f7b04f0168f6bbd17c340")
    add_versions("v2.8.9", "cfff42b9246e1e24d36ec4ae94a22d5f4b0a1c63c796babb5c2a13fe66aed5e9")
    add_versions("v2.8.13", "72c3e5affa8389442582e4cf67426376e2dff418e998e19822260f4bf58b74b8")

    add_deps("cmake", "nlohmann_json", "stb")

    on_install(function (package)
        io.replace("tiny_gltf.h", [[#include "json.hpp"]], "#include <nlohmann/json.hpp>", {plain = true})

        local configs = {
            "-DTINYGLTF_BUILD_LOADER_EXAMPLE=OFF",
            "-DTINYGLTF_HEADER_ONLY=ON",
            "-DTINYGLTF_INSTALL_VENDOR=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
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
