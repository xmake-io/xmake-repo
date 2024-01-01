package("vulkan-utility-libraries")
    set_homepage("https://github.com/KhronosGroup/Vulkan-Utility-Libraries")
    set_description("Utility libraries for Vulkan developers")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/Vulkan-Utility-Libraries/archive/refs/tags/v1.3.268.tar.gz",
             "https://github.com/KhronosGroup/Vulkan-Utility-Libraries.git")

    add_versions("v1.3.268", "990de84b66094b647ae420ba13356b79d69e1c6f95532f40466457d51a9d127d")

    if is_plat("windows") then
        add_syslinks("advapi32")
    end

    add_deps("cmake")
    add_deps("vulkan-headers")

    on_install("windows", "linux", "macosx", "bsd", "mingw", "msys", "cross", function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DUPDATE_DEPS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vkuCreateLayerSettingSet", {includes = "vulkan/layer/vk_layer_settings.h"}))
    end)
