package("directx-headers")

    set_homepage("https://github.com/microsoft/DirectX-Headers")
    set_description("Official DirectX headers")
    set_license("MIT")

    add_urls("https://github.com/microsoft/DirectX-Headers/archive/refs/tags/$(version).zip",
             "https://github.com/microsoft/DirectX-Headers.git")
    add_versions("v1.610.0", "ce8036d57e4b3b87167bf82a0236fc09cba4ffa7088322912b8ce82f284555db")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    if is_plat("mingw") then
        add_defines("__REQUIRED_RPCNDR_H_VERSION__=475")
    end

    on_install("windows", "mingw", function (package)
        local configs = {"-DDXHEADERS_BUILD_TEST=OFF", "-DDXHEADERS_BUILD_GOOGLE_TEST=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("CD3DX12FeatureSupport", {configs = {languages = "cxx14"}, includes = "directx/d3dx12.h"}))
    end)
