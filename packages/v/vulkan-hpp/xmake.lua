package("vulkan-hpp")

    set_homepage("https://github.com/KhronosGroup/Vulkan-Hpp/")
    set_description("Open-Source Vulkan C++ API")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/Vulkan-Hpp.git")
    add_versions("v1.2.180", "1ef8f08176b0b19a9dc8f917a773bcf9681058d1d15226508e8677961ca6ed1e")

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
