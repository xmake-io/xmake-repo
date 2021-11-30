package("vulkan-hpp")

    set_homepage("https://github.com/KhronosGroup/Vulkan-Hpp/")
    set_description("Open-Source Vulkan C++ API")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/Vulkan-Hpp.git")
    add_versions("v1.2.180", "bfa6d4765212505c8241a44b97dc5a9ce3aa2969")
    add_versions("v1.2.189", "58ff1da4c03f5f124eb835f41a9dd8fe3c2e8087")
    add_versions("v1.2.198", "d8c9f4f0eee6972622a1c3aabab5ed558d37c1c0")

    add_deps("cmake")

    on_install("windows", "linux", "macosx", function (package)
        import("package.tools.cmake").build(package, {buildir = "build"})
        os.mkdir("build")
        if package:is_plat("windows") then
            os.cp(path.join("**", "VulkanHppGenerator.exe"), "build")
        else
            os.cp(path.join("**", "VulkanHppGenerator"), "build")
        end
        os.runv(path.join("build", "VulkanHppGenerator"))
        os.cp("Vulkan-Headers/include", package:installdir())
        os.cp("vulkan/*.hpp", package:installdir(path.join("include", "vulkan")))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                vk::ApplicationInfo ai;
                ai.pApplicationName = "Test";
                ai.applicationVersion = VK_MAKE_API_VERSION(1,0,0,0);
                ai.pEngineName = "Test";
                ai.engineVersion = VK_MAKE_API_VERSION(1,0,0,0);
                ai.apiVersion = VK_API_VERSION_1_0;
            }
        ]]}, {includes = "vulkan/vulkan.hpp", configs = {languages = "c++11"} }))
    end)
