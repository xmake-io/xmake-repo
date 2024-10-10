package("directxtk12")
    set_homepage("https://github.com/Microsoft/DirectXTK12")
    set_description("A collection of helper classes for writing DirectX 12 code in C++")
    set_license("MIT")

    local tag = {
        ["2024.06"] = "jun2024",
        ["2024.09"] = "sep2024"
    }

    add_urls("https://github.com/microsoft/DirectXTK12.git")
    add_urls("https://github.com/microsoft/DirectXTK12/archive/refs/tags/$(version).tar.gz",
        { version = function (version) return tag[tostring(version)] end })

    add_versions("2024.06", "c543e2de8c9f8eeb83fcc39c5d142e02a190b57080449ac4785d3c4cb1e8dfe6")
    add_versions("2024.09", "03f76b5bd58b98697f078f17db8ecd73c408dfeed09c7788ce56a2db75a86e6d")

    add_configs("dxil_shaders",       { description = "Use DXC Shader Model 6 for shaders",           default = true,  type = "boolean" })
    add_configs("gameinput",          { description = "Build for GameInput",                          default = false, type = "boolean" })
    add_configs("mixed_dx11",         { description = "Support linking with DX11 version of toolkit", default = false, type = "boolean" })
    add_configs("testing",            { description = "Build the testing tree",                       default = true,  type = "boolean" })
    add_configs("wgi",                { description = "Build for Windows.Gaming.Input",               default = false, type = "boolean" })
    add_configs("xaudio_redist",      { description = "Build for XAudio2Redist",                      default = false, type = "boolean" })
    add_configs("xaudio_win10",       { description = "Build for XAudio 2.9",                         default = true,  type = "boolean" })
    add_configs("xinput",             { description = "Build for XInput",                             default = false, type = "boolean" })
    add_configs("spectre_mitigation", { description = "Build using /Qspectre for MSVC",               default = false, type = "boolean" })
    add_configs("iterator_debugging", { description = "Disable MSVC iterator debugging in Debug",     default = false, type = "boolean" })
    add_configs("prebuilt_shaders",   { description = "Use externally built HLSL shaders",            default = false, type = "boolean" })
    add_configs("no_wchar_t",         { description = "Use legacy wide-character as unsigned short",  default = false, type = "boolean" })

    add_configs("shared",             {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")

    if on_check then
        on_check("windows", function (package)
            local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
            if vs_toolset then
                local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
                local minor = vs_toolset_ver:minor()
                assert(minor and minor >= 30, "package(directxtk12) require vs_toolset >= 14.3")
            end
        end)
    end

    on_load(function (package)
        if package:is_plat("windows") then
            package:add("defines", "WIN32")
        end

        if package:config("mixed_dx11") then
            package:add("deps", "directxtk")
        end

        if package:config("gameinput") then
            package:add("defines", "USING_GAMEINPUT")
        end        
        if package:config("wgi") then
            package:add("defines", "USING_WINDOWS_GAMING_INPUT")
        end
        if package:config("xinput") then
            package:add("defines", "USING_XINPUT")
        end
    end)

    on_install("windows", function (package)
        local configs = {}

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_DXIL_SHADERS=" .. (package:config("dxil_shaders") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_GAMINPUT=" .. (package:config("gameinput") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_MIXED_DX11=" .. (package:config("mixed_dx11") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_TESTING=" .. (package:config("testing") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_WGI=" .. (package:config("wgi") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_XAUDIO_REDIST=" .. (package:config("xaudio_redist") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_XAUDIO_WIN10=" .. (package:config("xaudio_win10") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_XINPUT=" .. (package:config("xinput") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_ENABLE_SPECTRE_MITIGATION=" .. (package:config("spectre_mitigation") and "ON" or "OFF"))
        table.insert(configs, "-DDISABLE_MSVC_ITERATOR_DEBUGGING=" .. (package:config("iterator_debugging") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_PREBUILT_SHADERS=" .. (package:config("prebuilt_shaders") and "ON" or "OFF"))
        table.insert(configs, "-DNO_WCHAR_T=" .. (package:config("no_wchar_t") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({ test = [[
            void test() {
                DirectX::SimpleMath::Vector3 eye(0.0f, 0.7f, 1.5f);
                DirectX::SimpleMath::Vector3 at(0.0f, -0.1f, 0.0f);
                auto lookAt = DirectX::SimpleMath::Matrix::CreateLookAt(eye, at, DirectX::SimpleMath::Vector3::UnitY);
            }
        ]] }, {configs = {languages = "c++17"}, includes = "directxtk12/SimpleMath.h"}))
    end)
