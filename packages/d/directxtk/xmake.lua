package("directxtk")

    set_homepage("https://github.com/microsoft/DirectXTK")
    set_description("This package contains the \"DirectX Tool Kit\", a collection of helper classes for writing Direct3D 11 C++ code for Universal Windows Platform (UWP) apps for Windows 10, Xbox One, and Win32 desktop applications for Windows 7 Service Pack 1 or later.")

    set_urls("https://github.com/microsoft/DirectXTK/archive/$(version).zip",
             "https://github.com/microsoft/DirectXTK.git",
             {version = function (version)
                local versions = {
                    ["20.9.0"] = "sept2020",
                    ["21.4.0"] = "apr2021",
                    ["21.11.0"] = "nov2021"
                }
                return versions[tostring(version)]
            end})
    add_versions("20.9.0", "9d5131243bf3e33db2e3a968720d860abdcbbe7cb037c2cb5dd06046d439ed09")
    add_versions("21.4.0", "481e769b1aabd08b46659bbec8363a2429f04d3bb9a1e857eb0ebd163304d1bf")
    add_versions("21.11.0", "d25e634b0e225ae572f82d0d27c97051b0069c6813d7be12453039a504dffeb8")

    on_install("windows", function (package)
        local configs = {}
        local vs_sdkver = import("core.tool.toolchain").load("msvc"):config("vs_sdkver")
        if vs_sdkver then
            local build_ver = string.match(vs_sdkver, "%d+%.%d+%.(%d+)%.?%d*")
            assert(tonumber(build_ver) >= 19041, "DirectXTK requires Windows SDK to be at least 10.0.19041.0")
            table.insert(configs, "-DCMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION=" .. vs_sdkver)
            table.insert(configs, "-DCMAKE_SYSTEM_VERSION=" .. vs_sdkver)
        end
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        -- fix path issue with spaces
        io.replace("Src/Shaders/CompileShaders.cmd", " %1.hlsl ", " \"%1.hlsl\" ", {plain = true})
        io.replace("Src/Shaders/CompileShaders.cmd", " %1.fx ", " \"%1.fx\" ", {plain = true})
        import("package.tools.cmake").install(package, configs)
        os.cp("Inc/*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test()
            {
                DirectX::SimpleMath::Vector3 eye(0.0f, 0.7f, 1.5f);
                DirectX::SimpleMath::Vector3 at(0.0f, -0.1f, 0.0f);

                auto lookAt = DirectX::SimpleMath::Matrix::CreateLookAt(eye, at, DirectX::SimpleMath::Vector3::UnitY);
            }
        ]]}, {configs = {languages = "c++11"}, includes = { "windows.h", "SimpleMath.h" } }))
    end)
