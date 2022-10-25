package("d3d12-memory-allocator")
    set_homepage("https://github.com/GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator")
    set_description("Easy to integrate memory allocation library for Direct3D 12")
    set_license("MIT")

    add_urls("https://github.com/GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator/archive/refs/tags/$(version).tar.gz",
             "https://github.com/GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator.git")
    add_versions("v2.0.1", "7ce1f1dfb8821d0116eccf425b3558e6d4b28d192f4efb6e6bdb3d916d853574")

    add_deps("cmake")

    on_install("windows|x64", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        if package:config("shared") then
            os.mv(path.join(package:installdir("lib"), "*.dll"), package:installdir("bin"))
        end
    end)

    on_test("windows|x64", function (package)
        assert(package:check_cxxsnippets({test = [[
            static void test() {
                IDXGIFactory4* dxgi_factory;
                CreateDXGIFactory2(0, IID_PPV_ARGS(&dxgi_factory));

                IDXGIAdapter* adapter;
                dxgi_factory->EnumWarpAdapter(IID_PPV_ARGS(&adapter));

                ID3D12Device* device;
                D3D12CreateDevice(nullptr, D3D_FEATURE_LEVEL_11_1, IID_PPV_ARGS(&device));

                D3D12MA::ALLOCATOR_DESC allocatorDesc = {};
                allocatorDesc.pDevice = device;
                allocatorDesc.pAdapter = adapter;

                D3D12MA::Allocator* allocator;
                D3D12MA::CreateAllocator(&allocatorDesc, &allocator);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "D3D12MemAlloc.h"}))
    end)
