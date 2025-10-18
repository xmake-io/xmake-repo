package("diligenttools")
    set_homepage("https://github.com/DiligentGraphics/DiligentTools")
    set_description("Utilities built on top of core module")
    set_license("Apache-2.0")

    add_urls("https://github.com/DiligentGraphics/DiligentTools/archive/refs/tags/$(version).tar.gz",
             "https://github.com/DiligentGraphics/DiligentTools.git", {submodules = false})
    add_versions("v2.5.6", "6f2a99c15491396463cebe4f7fd1087db677b1531906ddf1864ad43346d3c2fc")

    add_patches("v2.5.6", "patches/v2.5.6/assetloader-include-diligentcore.diff", "a7259d5b9f2e34e1c0632d10a350bc78888dd000b8a28ac478b8e70835aedffc")
    add_patches("v2.5.6", "patches/v2.5.6/debundle-cmakelists.diff", "43476c90d5448ff5b87115c7a054c378bf130ad759f18dd297fa16307350aa22")
    add_patches("v2.5.6", "patches/v2.5.6/debundle-thirdparty-cmakelist.diff", "570158e31b0953568cf9b91e559bce5b062e4eb1aae5a0289a8d61af6d38be74")
    add_patches("v2.5.6", "patches/v2.5.6/fix-top-cmakelist.diff", "8e50585f7f6cf49c883819f62a45dfaadbe16bbe162c63761e111aba64c2c70a")
    add_patches("v2.5.6", "patches/v2.5.6/imgui-include-diligentcore.diff", "aa388d93decc6cb6ebbbd8ea72f476eb13e4a0871a8a16a14f0285f4ef4b5f97")
    add_patches("v2.5.6", "patches/v2.5.6/imguizmo-modified-include-diligentcore.diff", "6075c2b985b8657571ce70c3231960e5e2c1f39b7f163d2bf5e1762b359e54ec")
    add_patches("v2.5.6", "patches/v2.5.6/nativeapp-include-diligentcore.diff", "1e3f89542b2588f4be42b2c7a56f79f1cf0b0f149ea8bb8b6d52cd3c11c49e69")
    add_patches("v2.5.6", "patches/v2.5.6/renderstatenotation-include-diligentcore.diff", "7095306c24ff1de9a2ae274cd0b4631a341d4c212a48345a4ba6aca7fe7f34a0")
    add_patches("v2.5.6", "patches/v2.5.6/renderstatepackager-include-diligentcore.diff", "52dedf7f529649ecd837791f8d9758678685699eba82020517e0ede687c0601d")
    add_patches("v2.5.6", "patches/v2.5.6/textureloader-include-diligentcore.diff", "0613d5dfb5d5ce33a1fc97cb81d8c9a0eca1341639698a0a449c88aa3407b07c")

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
        add_deps("imgui 1.89", {configs = {win32 = true}})
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
        assert(package:check_cxxsnippets({test = [[
            #include <DiligentTools/Imgui/interface/ImGuiImplDiligent.hpp>
            void test() {
                Diligent::ImGuiDiligentCreateInfo info;
                Diligent::ImGuiImplDiligent impl(info);
                impl.InvalidateDeviceObjects();
            }
        ]]}, {configs = {languages = "c++17"}}))
        assert(package:check_cxxsnippets({test = [[
            #include <DiligentTools/RenderStateNotation/interface/RenderStateNotationLoader.h>
            void test() {
                Diligent::LoadPipelineStateInfo LoadInfo;
                Diligent::GraphicsPipelineStateCreateInfo PipelineCI{};
                LoadInfo.ModifyPipeline(PipelineCI, LoadInfo.pModifyPipelineData);
            }
        ]]}, {configs = {languages = "c++17"}}))
        assert(package:check_cxxsnippets({test = [[
            #include <DiligentTools/TextureLoader/interface/TextureUtilities.h>
            void test() {
                Diligent::PremultiplyAlphaAttribs Attribs;
                Diligent::PremultiplyAlpha(Attribs);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
