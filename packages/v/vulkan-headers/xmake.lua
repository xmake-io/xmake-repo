package("vulkan-headers")

    set_homepage("https://github.com/KhronosGroup/Vulkan-Headers/")
    set_description("Vulkan Header files and API registry")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/Vulkan-Headers/archive/$(version).tar.gz", {version = function (version) return version:startswith("v") and version or "sdk-" .. version:gsub("%+", ".") end})
    add_versions("1.2.162+0", "eb0f6a79ac38e137f55a0e13641140e63b765c8ec717a65bf3904614ef754365")
    add_versions("1.2.154+0", "a0528ade4dd3bd826b960ba4ccabc62e92ecedc3c70331b291e0a7671b3520f9")

    add_deps("cmake")

    on_install("windows", "linux", "macosx", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                int version = VK_HEADER_VERSION;
            }
        ]]}, {includes = "vulkan/vulkan.h"}))
    end)
