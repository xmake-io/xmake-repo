package("directx-headers")
    set_homepage("https://devblogs.microsoft.com/directx/")
    set_description("Official DirectX headers available under an open source license")
    set_license("MIT")

    add_urls("https://github.com/microsoft/DirectX-Headers/archive/refs/tags/$(version).tar.gz",
             "https://github.com/microsoft/DirectX-Headers.git")
    add_versions("v1.606.4", "fa95f9ab7cd6111a4cbff91f5b440bf79b38179403c9eef22438065b8b08d303")

    add_deps("cmake")

    on_install("windows", function (package)
        local configs = {"-DDXHEADERS_BUILD_TEST=OFF", "-DDXHEADERS_BUILD_GOOGLE_TEST=OFF"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("ID3D12Device", {configs = {languages = "c++11"}, includes = {"directx/d3d12.h"}}))
    end)
