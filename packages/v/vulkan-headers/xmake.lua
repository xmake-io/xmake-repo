package("vulkan-headers")

    set_homepage("https://github.com/KhronosGroup/Vulkan-Headers/")
    set_description("Vulkan Header files and API registry")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/Vulkan-Headers/archive/$(version).tar.gz")
    add_versions("v1.2.154", "b636f0ace2c2b8a7dbdfddf16c53c1f49a4b39d6da562727bfea00b5ec447537")
    add_versions("v1.2.162", "deab1a7a28ad3e0a7a0a1c4cd9c54758dce115a5f231b7205432d2bbbfb4d456")

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
