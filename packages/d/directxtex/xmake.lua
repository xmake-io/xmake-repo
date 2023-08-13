package("directxtex")
    set_homepage("https://walbourn.github.io/directxtex/")
    set_description("DirectXTex texture processing library")
    set_license("MIT")

    local tag =
    {
        ["2023.06"] = "jun2023",
    }

    add_urls("https://github.com/microsoft/DirectXTex/archive/refs/tags/$(version).tar.gz",
             "https://github.com/microsoft/DirectXTex.git", {version = function (version) return tag[tostring(version)] end})

    add_versions("2023.06", "51f0ff3bee0d1015c110e0c92ebdd9704aa6acd91185328fd92f10b9558f4c62")

    add_configs("dx11", {description = "Build with DirectX11 Runtime support", default = true, type = "boolean"})
    add_configs("dx12", {description = "Build with DirectX12 Runtime support", default = true, type = "boolean"})
    add_configs("openmp", {description = "Build with OpenMP support", default = false, type = "boolean"})
    add_configs("spectre", {description = "Build using /Qspectre for MSVC", default = false, type = "boolean"})
    add_configs("iterator_debugging", {description = "Disable iterator debugging in Debug configurations with the MSVC CRT", default = false, type = "boolean"})
    add_configs("code_analysis", {description = "Use Static Code Analysis on build", default = false, type = "boolean"})
    add_configs("prebuild_shader", {description = "Use externally built HLSL shaders", default = false, type = "boolean"})
    add_configs("openexr", {description = "Build with OpenEXR support", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("openexr") then
            package:add("deps", "openexr")
        end
    end)

    on_install("windows", function (package)
        local configs = {"-DBUILD_TOOLS=OFF", "-DBUILD_SAMPLE=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_DX11=" .. (package:config("dx11") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_DX12=" .. (package:config("dx12") and "ON" or "OFF"))
        table.insert(configs, "-DBC_USE_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SPECTRE_MITIGATION=" .. (package:config("spectre") and "ON" or "OFF"))
        table.insert(configs, "-DDISABLE_MSVC_ITERATOR_DEBUGGING=" .. (package:config("iterator_debugging") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_CODE_ANALYSIS=" .. (package:config("code_analysis") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_PREBUILT_SHADERS=" .. (package:config("prebuild_shader") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_OPENEXR_SUPPORT=" .. (package:config("openexr") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <DirectXTex.h>
            void test() {
                DirectX::IsValid(DXGI_FORMAT_UNKNOWN);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
