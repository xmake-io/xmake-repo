package("magnum")

    set_homepage("https://magnum.graphics/")
    set_description("Light­weight and mod­u­lar C++11/C++14 graph­ics mid­dle­ware for games and data visu­al­iz­a­tion.")
    set_license("MIT")

    add_urls("https://github.com/mosra/magnum/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mosra/magnum.git")
    add_versions("v2020.06", "98dfe802e56614e4e6bf750d9b693de46a5ed0c6eb479b0268f1a20bf34268bf")

    add_configs("audio", {description = "Build audio module.", default = false, type = "boolean"})
    add_configs("vulkan", {description = "Build vulkan module.", default = false, type = "boolean"})

    add_deps("cmake", "corrade", "opengl")
    add_links("MagnumAudio", "MagnumDebugTools", "MagnumGL", "MagnumMeshTools", "MagnumPrimitives", "MagnumSceneGraph", "MagnumShaders", "MagnumText", "MagnumTextureTools", "MagnumTrade", "MagnumVk", "Magnum")
    on_load("windows", "linux", "macosx", function (package)
        if package:config("audio") then
            package:add("deps", "openal-soft", {configs = {shared = true}})
        end
        if package:config("vulkan") then
            package:add("deps", "vulkansdk")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DLIB_SUFFIX="}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DWITH_AUDIO=" .. (package:config("audio") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_VK=" .. (package:config("vulkan") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {buildir = os.tmpdir()})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <Magnum/GL/Buffer.h>
            #include <Magnum/Math/Color.h>
            using namespace Magnum;
            struct TriangleVertex {
                Vector2 position;
                Color3 color;
            };
            void test() {
                using namespace Math::Literals;
                const TriangleVertex data[]{
                    {{-0.5f, -0.5f}, 0xff0000_rgbf},
                    {{ 0.5f, -0.5f}, 0x00ff00_rgbf},
                    {{ 0.0f,  0.5f}, 0x0000ff_rgbf}
                };
                GL::Buffer buffer;
                buffer.setData(data);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
