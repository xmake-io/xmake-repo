package("directx-headers")

    set_homepage("https://github.com/microsoft/DirectX-Headers")
    set_description("Official DirectX headers")
    set_license("MIT")

    add_urls("https://github.com/microsoft/DirectX-Headers/archive/refs/tags/$(version).zip",
             "https://github.com/microsoft/DirectX-Headers.git")
    add_versions("v1.618.2", "89d146e806fdc2cdc0fe8aa54731ae039c6ff5a6d88fe002df726fe80ae565fd")
    add_versions("v1.618.1", "5f349114248df8bce4539d997bc76ebc63b56d3c6b964ed275b60b749dbd3c6c")
    add_versions("v1.616.0", "09e9c218d04fe34e1f12c21ec8188983a034e223b8fbfb3ec2ab1573dd03c39e")
    add_versions("v1.615.0", "0c2b0ee35e742725fa91e070cfec39aa2f48e9b63f6b0227faba0f4cca825799")
    add_versions("v1.614.1", "ffdf333bfd867bdf32f69898ab822c53922744cc7797729090a7c2b2e63e4982")
    add_versions("v1.614.0", "9305df61de9916cc206b3b466fcb0afa4312664ef512f93939242adcfa029554")
    add_versions("v1.613.1", "c356d242e63f6c8e6fa8dec01f7d526b172621f0f6687611239f772095842e4c")
    add_versions("v1.613.0", "38852327d998e54d9faac93be28c1f8b6489442832eb380004e2fecedd907eef")
    add_versions("v1.610.0", "ce8036d57e4b3b87167bf82a0236fc09cba4ffa7088322912b8ce82f284555db")

    add_patches("1.610.0", path.join(os.scriptdir(), "patches", "1.610.0", "mingw.patch"), "7409d90adb1513e8683cc6d16aba1a3e73643c3e04b9af70474a5b13323be0fb")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    if is_plat("mingw") then
        add_defines("__REQUIRED_RPCNDR_H_VERSION__=475")
    elseif is_plat("linux") then
        add_includedirs("include", "include/wsl/stubs")
    end

    on_install("windows", "mingw", "linux", function (package)
        local configs = {"-DDXHEADERS_BUILD_TEST=OFF", "-DDXHEADERS_BUILD_GOOGLE_TEST=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if package:is_plat("windows", "mingw") then
            assert(package:has_cxxtypes("CD3DX12FeatureSupport", {configs = {languages = "cxx14"}, includes = "directx/d3dx12.h"}))
        else
            assert(package:has_cxxincludes("wsl/winadapter.h", {configs = {languages = "cxx14"}}))
        end
    end)
