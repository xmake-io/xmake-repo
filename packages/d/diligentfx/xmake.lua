package("diligentfx")
    set_homepage("https://github.com/DiligentGraphics/DiligentFX")
    set_description("High-level rendering components")
    set_license("Apache-2.0")

    add_urls("https://github.com/DiligentGraphics/DiligentFX/archive/refs/tags/$(version).tar.gz",
             "https://github.com/DiligentGraphics/DiligentFX.git")
    add_versions("v2.5.6", "5adaf8df5297c0e4218b3945228b488fead21f15dac781c52677c03958833979")

    add_patches("v2.5.6", "patches/v2.5.6/components-include-diligentcore.diff", "1fc874df79fb8565bb560df42f52b5a5b81778807c1a392d4f556c2805b95a1f")
    add_patches("v2.5.6", "patches/v2.5.6/debundle-thirdparty-cmakelist.diff", "e5b6095c35d49a018ed8c3bda6ba55647c882817429d9a1b73d8f05b71b58144")
    add_patches("v2.5.6", "patches/v2.5.6/fix-top-cmakelist.diff", "a1485b9d6ddedd4e1f30cc2fb778fdc734dd09e747d7e27f49ee8e0992c6070c")
    add_patches("v2.5.6", "patches/v2.5.6/hydrogent-include-diligentcore.diff", "2737c88f0772f4f1e2752683fe1cbc12b3762f200ba15ebd54b496c6abafe3e0")
    add_patches("v2.5.6", "patches/v2.5.6/hydrogent-interface-include-diligentcore.diff", "9068fa0a206740c9517e87df7e9be4b793a9f666b94ca302fd3ff9e5fdfb258c")
    add_patches("v2.5.6", "patches/v2.5.6/hydrogent-interface-tasks-include-diligentcore.diff", "12d3041762c70e0930042cece30025b8fe21271afeeb8b6ce114ffe3bfa8f500")
    add_patches("v2.5.6", "patches/v2.5.6/hydrogent-src-include-diligentcore.diff", "7e2442f999b399d58340d89ff2e2a8d5f87cdd7abf694d928037ea7208f657d6")
    add_patches("v2.5.6", "patches/v2.5.6/pbr-include-diligentcore.diff", "d8027308a8d7f217fd702035d2374235407eeb77c19df09a5a0e8a27f5b2d8a4")
    add_patches("v2.5.6", "patches/v2.5.6/postprocess-common-include-diligentcore.diff", "81972463e0ea76d6ce5939d52e4aa21f040d67590b82da4a84b1ee8aa6032d1b")
    add_patches("v2.5.6", "patches/v2.5.6/postprocess-include-diligentcore.diff", "874a20e9ab0dcccd87ed04aef4f1157e6b238c36b85af8151a3e24feb38e6fc6")
    add_patches("v2.5.6", "patches/v2.5.6/postprocess-src-include-diligentcore.diff", "c4baf131dd92626e25face7dd125fb03169c52da09ce8d133ad972b32de157ba")
    add_patches("v2.5.6", "patches/v2.5.6/utilities-include-diligentcore.diff", "983494a7b153bf7ba6b166e35a32b244e7a54d51e27cbd1fd33288a2f3700030")

    add_resources("v2.5.6", "DiligentCore_source", "https://github.com/DiligentGraphics/DiligentCore/archive/refs/tags/v2.5.6.tar.gz", "abc190c05ee7e5ef2bba52fcbc5fdfe2256cce3435efba9cfe263a386653f671")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_includedirs("include", "include/DiligentFX")

    add_deps("cmake", "pkgconf")
    add_deps("diligentcore", "diligenttools", "entt", "usd", "imgui")
    add_deps("python 3.x", {kind = "binary"})

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
    end)

    on_install("linux|!arm64", "macosx|x86_64", "windows|x64", function (package)
        local resourcedir = package:resourcedir("DiligentCore_source")
        if resourcedir then
            os.cp(
                path.join(resourcedir, "DiligentCore-2.5.6", "BuildTools", "CMake", "BuildUtils.cmake"), 
                "DiligentCoreBuildUtils.cmake"
            )
            os.cp(
                path.join(resourcedir, "DiligentCore-2.5.6", "BuildTools", "File2Include", "script.py"), 
                "script.py"
            )
            os.cp(
                path.join(resourcedir, "DiligentCore-2.5.6"), 
                "DiligentCore-2.5.6"
            )
        end
        local configs = {"-DDILIGENT_INSTALL_FX=ON"}
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
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <DiligentFX/Components/interface/ShadowMapManager.hpp>
            void test() {
                Diligent::ShadowMapManager* sMM = new Diligent::ShadowMapManager();
                auto srv = sMM->GetSRV();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
