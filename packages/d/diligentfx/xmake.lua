package("diligentfx")
    set_homepage("https://github.com/DiligentGraphics/DiligentFX")
    set_description("High-level rendering components")
    set_license("Apache-2.0")

    add_urls("https://github.com/DiligentGraphics/DiligentFX/archive/refs/tags/$(version).tar.gz",
             "https://github.com/DiligentGraphics/DiligentFX.git")
    add_versions("v2.5.6", "5adaf8df5297c0e4218b3945228b488fead21f15dac781c52677c03958833979")

    add_patches("v2.5.6", "patches/v2.5.6/build.diff", "e42bfa8bf62485d0a7008a1b5c070e39e9ead31f15393da6b25724672841ffc8")

    add_resources("v2.5.6", "DiligentCore_source", "https://github.com/DiligentGraphics/DiligentCore/archive/refs/tags/v2.5.6.tar.gz", "abc190c05ee7e5ef2bba52fcbc5fdfe2256cce3435efba9cfe263a386653f671")

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

    on_install("linux", "macosx|x86_64", "windows|x64", function (package)
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
        print(configs)
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
