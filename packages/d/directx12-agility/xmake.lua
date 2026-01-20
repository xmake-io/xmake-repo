package("directx12-agility")
    set_homepage("https://devblogs.microsoft.com/directx/directx-12-agility-sdk")
    set_description("DirectX 12 Agility SDK")
    set_license("Microsoft")

    set_urls("https://www.nuget.org/api/v2/package/Microsoft.Direct3D.D3D12/$(version)/#Microsoft.DXSDK.D3DX-$(version).zip")
    add_versions("1.618.1", "35a1bb4139f751e19956a0471fb621442450c63b1f100752b27ada6abed7a3da")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    add_deps("cmake")

    add_syslinks("d3d12")

    on_install("windows", function (package)
        os.cp("build/native/include", package:installdir())
        local REDIST_ARCH = ""
        if package:is_arch("arm64") then
            REDIST_ARCH = "arm64"
        elseif not package:is_arch("arm.*") and package:is_arch64() then
            REDIST_ARCH = "x64"
        elseif not package:is_arch("arm.*") and not package:is_arch64() then
            REDIST_ARCH = "win32"
        end
        os.cp(path.join("build/native/bin", REDIST_ARCH, "D3D12Core.dll"), package:installdir("bin"))
        os.cp(path.join("build/native/bin", REDIST_ARCH, "D3D12Core.pdb"), package:installdir("bin"))
        os.cp(path.join("build/native/bin", REDIST_ARCH, "d3d12SDKLayers.dll"), package:installdir("bin"))
        os.cp(path.join("build/native/bin", REDIST_ARCH, "d3d12SDKLayers.pdb"), package:installdir("bin"))
        os.cp(path.join("build/native/bin", REDIST_ARCH, "d3dconfig.exe"), package:installdir("bin"))
        os.cp(path.join("build/native/bin", REDIST_ARCH, "d3dconfig.pdb"), package:installdir("bin"))
        os.cp(path.join(package:scriptdir(), "port/directx12-agility-targets.cmake.in"), "directx12-agility-targets.cmake.in")
        os.cp(path.join(package:scriptdir(), "port/directx12-agility-config.cmake.in"), "directx12-agility-config.cmake.in")
        os.cp(path.join(package:scriptdir(), "port/directx12-agility.pc.in"), "directx12-agility.pc.in")
        os.cp(path.join(package:scriptdir(), "port/cmakelists.txt"), "CMakeLists.txt")
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DVERSION=" .. package:version()
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
	            IDXGIAdapter1* dxgiAdapter = nullptr;
                ID3D12Device* device = nullptr;
                D3D12CreateDevice(dxgiAdapter, D3D_FEATURE_LEVEL_12_0, IID_PPV_ARGS(&device));
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"dxgi.h", "d3d12.h"}}))
    end)
