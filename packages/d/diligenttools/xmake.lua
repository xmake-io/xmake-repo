package("diligenttools")
    set_homepage("https://github.com/DiligentGraphics/DiligentTools")
    set_description("Utilities built on top of core module")
    set_license("Apache-2.0")

    add_urls("https://github.com/DiligentGraphics/DiligentTools/archive/refs/tags/$(version).tar.gz",
             "https://github.com/DiligentGraphics/DiligentTools.git", {submodules = false})
    add_versions("v2.5.6", "6f2a99c15491396463cebe4f7fd1087db677b1531906ddf1864ad43346d3c2fc")
    add_patches("v2.5.6", "patches/v2.5.6/build.diff", "847d50b03e216fc1c2c2c5d2455e6543c52562a9586e634384e7d2a6b5302716")
    add_resources("v2.5.6", "DiligentCore_source", "https://github.com/DiligentGraphics/DiligentCore/archive/refs/tags/v2.5.6.tar.gz", "abc190c05ee7e5ef2bba52fcbc5fdfe2256cce3435efba9cfe263a386653f671")

    add_configs("shared",               {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("rsp",                  {description = "Enable Render State Packager", default = true, type = "boolean"})
    add_configs("rapidjson",            {description = "Enable rapidjson", default = true, type = "boolean"})
    add_configs("draco",                {description = "Enable draco", default = true, type = "boolean"})

    add_includedirs("include", "include/DiligentTools")

    add_deps("cmake", "pkgconf")
    add_deps("python 3.x", {kind = "binary"})
    add_deps("diligentcore", "libpng", "libtiff", "zlib", "libjpeg", "taywee_args", "nlohmann_json", "stb", "tinygltf")

    if is_plat("windows") then
        add_deps("imgui", {configs = {win32 = true}})
    elseif is_plat("linux") then
        add_deps("imgui 1.89", "libxcb", "libx11", "libxrandr", "libxrender", "libxinerama", "libxfixes", "libxcursor", "libxi", "libxext", "wayland")
    elseif is_plat("macosx") then
        add_deps("imgui 1.85", {configs = {osx = true}})
    end

    if is_plat("windows") then
        add_syslinks("comdlg32")
    elseif is_plat("macosx") then
        add_frameworks("Cocoa")
    end

    on_load(function (package)
        local diligentcore = package:dep("diligentcore")
        if diligentcore then
            if not diligentcore:is_system() then
                local diligentcore_fetchinfo = diligentcore:fetch()
                print("DiligentCore fetchinfo.defines => ")
                print(diligentcore_fetchinfo.defines)
                for _, define in ipairs(diligentcore_fetchinfo.defines) do
                    package:add("defines", define)
                end
            end
        end
        if package:config("rapidjson") then
            package:add("deps", "rapidjson")
        end
        if package:config("draco") then
            package:add("deps", "draco")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local resourcedir = package:resourcedir("DiligentCore_source")
        if resourcedir then
            os.cp(
                path.join(resourcedir, "DiligentCore-2.5.6", "BuildTools", "CMake", "BuildUtils.cmake"), 
                "BuildUtils.cmake"
            )
        end
        local configs = {"-DDILIGENT_INSTALL_TOOLS=ON"}
        local diligentcore = package:dep("diligentcore")
        if diligentcore then
            if not diligentcore:is_system() then
                local diligentcore_fetchinfo = diligentcore:fetch()
                print("DiligentCore fetchinfo.defines => ")
                print(diligentcore_fetchinfo.defines)
                for _, define in ipairs(diligentcore_fetchinfo.defines) do
                    if define:find("PLATFORM") or define:find("_SUPPORTED") then
                        table.insert(configs, "-D" .. define .. "=ON")
                    end
                end
            end
        end
        table.insert(configs, "-DDILIGENT_NO_RENDER_STATE_PACKAGER=" .. (package:config("rsp") and "OFF" or "ON"))
        table.insert(configs, "-DDILIGENT_USE_RAPIDJSON=" .. (package:config("rapidjson") and "ON" or "OFF"))
        table.insert(configs, "-DDILIGENT_ENABLE_DRACO=" .. (package:config("draco") and "ON" or "OFF"))
        local packagedeps = {}
        if package:config("draco") then
            table.insert(packagedeps, "draco")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <DiligentTools/AssetLoader/interface/GLTFLoader.hpp>
            void test() {
                Diligent::GLTF::Material material;
                auto count = material.GetNumActiveTextureAttribs();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <DiligentTools/Imgui/interface/ImGuiImplDiligent.hpp>
            void test() {
                Diligent::ImGuiDiligentCreateInfo info;
                Diligent::ImGuiImplDiligent impl(info);
                impl.InvalidateDeviceObjects();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <DiligentTools/RenderStateNotation/interface/RenderStateNotationParser.h>
            void test() {
                Diligent::RenderStateNotationParserInfo ParserInfo;
                auto info = ParserInfo.GetInfo();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <DiligentTools/TextureLoader/interface/TextureUtilities.h>
            void test() {
                Diligent::PremultiplyAlphaAttribs Attribs;
                Diligent::PremultiplyAlpha(Attribs);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
