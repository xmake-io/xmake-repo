package("magnum")

    set_homepage("https://magnum.graphics/")
    set_description("Lightweight and modular C++11/C++14 graphics middleware for games and data visualization.")
    set_license("MIT")

    add_urls("https://github.com/mosra/magnum/archive/refs/tags/$(version).zip",
             "https://github.com/mosra/magnum.git")
    add_versions("v2020.06", "78c52bc403cec27b98d8d87186622ca57f8d70ffd64342fe4094c720b7d3b0e3")

    add_patches("2020.06", "patches/2020.06/msvc.patch", "0739a29807c6aeb4681eaadb4c624c39f5d1ba746de3df7ab83801f41d1ad5bd")

    add_configs("audio",         {description = "Build Audio library.", default = false, type = "boolean"})
    add_configs("meshtools",     {description = "Build MeshTools library.", default = true, type = "boolean"})
    add_configs("opengl",        {description = "Build GL library.", default = true, type = "boolean"})
    add_configs("vulkan",        {description = "Build Vk library.", default = false, type = "boolean"})
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

    add_deps("cmake", "corrade")
    on_load("windows", "linux", "macosx", function (package)
        if package:config("audio") then
            package:add("deps", "openal-soft", {configs = {shared = true}})
        end
        if package:config("opengl") then
            package:add("deps", "opengl")
        end
        if package:config("vulkan") then
            package:add("deps", "vulkansdk")
        end
        if package:config("glfw") then
            package:add("deps", "glfw")
        end
        if package:config("sdl2") then
            package:add("deps", "libsdl2", {configs = {sdlmain = false}})
        end
        if package:config("glx") then
            package:add("deps", "libx11")
        end
        local links = {"MagnumAnyAudioImporter", "MagnumAnyImageConverter", "MagnumAnyImageImporter", "MagnumAnySceneConverter", "MagnumAnySceneImporter", "MagnumMagnumFont", "MagnumMagnumFontConverter", "MagnumObjImporter", "MagnumTgaImageConverter", "MagnumTgaImporter", "MagnumWavAudioImporter"}
        table.join2(links, {"MagnumCglContext", "MagnumEglContext", "MagnumGlxContext", "MagnumWglContext", "MagnumOpenGLTester", "MagnumVulkanTester"})
        table.join2(links, {"MagnumAndroidApplication", "MagnumEmscriptenApplication", "MagnumGlfwApplication", "MagnumGlxApplication", "MagnumSdl2Application", "MagnumXEglApplication", "MagnumWindowlessCglApplication", "MagnumWindowlessEglApplication", "MagnumWindowlessGlxApplication", "MagnumWindowlessIosApplication", "MagnumWindowlessWglApplication", "MagnumWindowlessWindowsEglApplication"})
        table.join2(links, {"MagnumAudio", "MagnumDebugTools", "MagnumGL", "MagnumMeshTools", "MagnumPrimitives", "MagnumSceneGraph", "MagnumShaders", "MagnumText", "MagnumTextureTools", "MagnumTrade", "MagnumVk", "Magnum"})
        local postfix = package:debug() and "-d" or ""
        for _, link in ipairs(links) do
            package:add("links", link .. postfix)
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        io.replace("modules/FindSDL2.cmake", "SDL2-2.0 SDL2", "SDL2-2.0 SDL2 SDL2-static", {plain = true})
        io.replace("modules/FindSDL2.cmake", "${_SDL2_LIBRARY_PATH_SUFFIX}", "lib ${_SDL2_LIBRARY_PATH_SUFFIX}", {plain = true})
        local configs = {"-DBUILD_TESTS=OFF", "-DLIB_SUFFIX="}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DWITH_AUDIO=" .. (package:config("audio") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_MESHTOOLS=" .. (package:config("meshtools") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_GL=" .. (package:config("opengl") and "ON" or "OFF"))
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
        import("package.tools.cmake").install(package, configs, {builddir = os.tmpfile() .. ".dir"})
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
