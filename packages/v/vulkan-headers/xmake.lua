package("vulkan-headers")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/KhronosGroup/Vulkan-Headers/")
    set_description("Vulkan Header files and API registry")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/Vulkan-Headers/archive/$(version).tar.gz", {version = function (version) return version:startswith("v") and version or "sdk-" .. version:gsub("%+", ".") end})
    add_versions("1.3.246+1", "f9fa6a05ac1e059cd6f8f3a21705fb5bc093743d97315b7acf3bc20921abc27c")
    add_versions("1.3.239+0", "865fa8e8e8314fcca60777a92f50bd0cf612205a36e719d6975482d3366f619e")
    add_versions("1.3.236+0", "2df85b3daa78ced7f910db870ea2aed10f718c703e18076b4549ca4005c9c451")
    add_versions("1.3.231+1", "6e16051ccb28821b907a08025eedb82cc73e1056924b32f75880ecae2499f7f6")
    add_versions("1.3.211+0", "c464bcdc24b7541ac4378a270617a23d4d92699679a73f95dc4b9e1da924810a")
    add_versions("1.2.198+0", "34782c61cad9b3ccf2fa0a31ec397d4fce99490500b4f3771cb1a48713fece80")
    add_versions("1.2.189+1", "ce2eb5995dddd8ff2cee897ab91c30a35d6096d5996fc91cec42bfb37112d3f8")
    add_versions("1.2.182+0", "61c05dc8a24d5a9104ca2cd233cb9febc3455d69a64e404c3535293f3a463d02")
    add_versions("1.2.162+0", "eb0f6a79ac38e137f55a0e13641140e63b765c8ec717a65bf3904614ef754365")
    add_versions("1.2.154+0", "a0528ade4dd3bd826b960ba4ccabc62e92ecedc3c70331b291e0a7671b3520f9")

    add_deps("cmake")

    if is_plat("linux") then
        add_extsources("pacman::vulkan-headers")
    end

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                int version = VK_HEADER_VERSION;
            }
        ]]}, {includes = "vulkan/vulkan.h"}))
    end)
