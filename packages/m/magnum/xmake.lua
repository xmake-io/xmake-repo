package("magnum")

    set_homepage("https://magnum.graphics/")
    set_description("Lightweight and modular C++11/C++14 graphics middleware for games and data visualization.")
    set_license("MIT")

    add_urls("https://github.com/mosra/magnum/archive/refs/tags/$(version).zip",
             "https://github.com/mosra/magnum.git")
    add_versions("v2020.06", "78c52bc403cec27b98d8d87186622ca57f8d70ffd64342fe4094c720b7d3b0e3")

    add_configs("audio",         {description = "Build audio module.", default = false, type = "boolean"})
    add_configs("vulkan",        {description = "Build vulkan module.", default = false, type = "boolean"})
    add_configs("deprecated",    {description = "Include deprecated APIs in the build.", default = true, type = "boolean"})
    add_configs("plugin_static", {description = "Build plugins as static libraries.", default = false, type = "boolean"})

    local applicationlibs = {"android", "emscripten", "glfw", "glx", "sdl2", "xegl", "windowlesscgl", "windowlessegl", "windowlessglx", "windowlessios", "windowlesswgl", "windowlesswindowsegl"}
    for _, applicationlib in ipairs(applicationlibs) do
        add_configs(applicationlib, {description = "Build the " .. applicationlib .. " application library.", default = false, type = "boolean"})
    end

    local contexts = {"cgl", "egl", "glx", "wgl"}
    for _, context in ipairs(contexts) do
        add_configs(context .. "context", {description = "Build the " .. context .. " context handling library.", default = false, type = "boolean"})
    end

    local testers = {"opengltester", "vulkantester"}
    for _, tester in ipairs(testers) do
        add_configs(tester, {description = "Build the " .. tester .. " class.", default = false, type = "boolean"})
    end

    local plugins = {"anyaudioimporter", "anyimageconverter", "anyimageimporter", "anysceneconverter", "anysceneimporter", "anyshaderconverter", "magnumfont", "magnumfontconverter", "objimporter", "tgaimporter", "tgaimageconverter", "wavaudioimporter"}
    for _, plugin in ipairs(plugins) do
        add_configs(plugin, {description = "Build the " .. plugin .. " plugin.", default = false, type = "boolean"})
    end

    local utilities = {"gl_info", "vk_info", "al_info", "distancefieldconverter", "fontconverter", "imageconverter", "sceneconverter", "shaderconverter"}
    for _, utility in ipairs(utilities) do
        add_configs(utility, {description = "Build the " .. utility .. " executable.", default = false, type = "boolean"})
    end

    add_deps("cmake", "corrade", "opengl")
    add_links("MagnumAnyAudioImporter", "MagnumAnyImageConverter", "MagnumAnyImageImporter", "MagnumAnySceneConverter", "MagnumAnySceneImporter", "MagnumMagnumFont", "MagnumMagnumFontConverter", "MagnumObjImporter", "MagnumTgaImageConverter", "MagnumTgaImporter", "MagnumWavAudioImporter")
    add_links("MagnumCglContext", "MagnumEglContext", "MagnumGlxContext", "MagnumWglContext", "MagnumOpenGLTester", "MagnumVulkanTester")
    add_links("MagnumAndroidApplication", "MagnumEmscriptenApplication", "MagnumGlfwApplication", "MagnumGlxApplication", "MagnumSdl2Application", "MagnumXEglApplication", "MagnumWindowlessCglApplication", "MagnumWindowlessEglApplication", "MagnumWindowlessGlxApplication", "MagnumWindowlessIosApplication", "MagnumWindowlessWglApplication", "MagnumWindowlessWindowsEglApplication")
    add_links("MagnumAudio", "MagnumDebugTools", "MagnumGL", "MagnumMeshTools", "MagnumPrimitives", "MagnumSceneGraph", "MagnumShaders", "MagnumText", "MagnumTextureTools", "MagnumTrade", "MagnumVk", "Magnum")
    on_load("windows", "linux", "macosx", function (package)
        if package:config("audio") then
            package:add("deps", "openal-soft", {configs = {shared = true}})
        end
        if package:config("vulkan") then
            package:add("deps", "vulkansdk")
        end
        if package:config("glfw") then
            package:add("deps", "glfw")
        end
        if package:config("sdl2") then
            package:add("deps", "libsdl")
        end
        if package:config("glx") then
            package:add("deps", "libx11")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DLIB_SUFFIX="}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DWITH_AUDIO=" .. (package:config("audio") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_VK=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_DEPRECATED=" .. (package:config("deprecated") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_PLUGIN_STATIC=" .. (package:config("plugin_static") and "ON" or "OFF"))
        for _, applicationlib in ipairs(applicationlibs) do
            table.insert(configs, "-DWITH_" .. applicationlib:upper() .. "APPLICATION=" .. (package:config(applicationlib) and "ON" or "OFF"))
        end
        for _, context in ipairs(contexts) do
            table.insert(configs, "-DWITH_" .. context:upper() .. "CONTEXT=" .. (package:config(context) and "ON" or "OFF"))
        end
        for _, tester in ipairs(testers) do
            table.insert(configs, "-DWITH_" .. tester:upper() .. "=" .. (package:config(tester) and "ON" or "OFF"))
        end
        for _, plugin in ipairs(plugins) do
            table.insert(configs, "-DWITH_" .. plugin:upper() .. "=" .. (package:config(plugin) and "ON" or "OFF"))
        end
        for _, utility in ipairs(utilities) do
            table.insert(configs, "-DWITH_" .. utility:upper() .. "=" .. (package:config(utility) and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs, {buildir = os.tmpfile() .. ".dir"})
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
