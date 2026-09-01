package("gltf-sdk")
    set_homepage("https://github.com/microsoft/glTF-SDK")
    set_description("glTF-SDK is a C++ Software Development Kit for glTF (GL Transmission Format -https://github.com/KhronosGroup/glTF).")
    set_license("MIT")

    add_urls("https://github.com/microsoft/glTF-SDK/archive/refs/tags/$(version).tar.gz",
             "https://github.com/microsoft/glTF-SDK.git", {
                version = function (version)
                    return "r" .. version:gsub("+", ".")
                end
            })

    add_versions("1.9.6+0", "f3049d2b8ecebb914f634496918ab645f7ce452a67a5b4210e7354dc7c0059ab")

    add_deps("cmake")
    add_deps("rapidjson")

    on_install(function (package)
        local configs = {
            "-DENABLE_UNIT_TESTS=OFF",
            "-DENABLE_SAMPLES=OFF",
            "-DRAPIDJSON_BUILD_DOC=OFF",
            "-DRAPIDJSON_BUILD_EXAMPLES=OFF",
            "-DRAPIDJSON_BUILD_TESTS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using namespace Microsoft::glTF;
                const Color3 c1 = { 0.0f, 0.0f, 0.0f };
                Color3 c = c1.ToGamma();
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"GLTFSDK/Color.h"}}))
    end)
