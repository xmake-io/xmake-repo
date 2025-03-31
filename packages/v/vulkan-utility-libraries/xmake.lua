package("vulkan-utility-libraries")
    set_homepage("https://github.com/KhronosGroup/Vulkan-Utility-Libraries")
    set_description("Utility libraries for Vulkan developers")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/Vulkan-Utility-Libraries/archive/refs/tags/$(version).tar.gz", {alias = "archive", version = function (version)
        local prefix = ""
        if version:gt("1.3.261+1") then
            prefix = "vulkan-sdk-"
        elseif version:ge("1.3.226") then
            prefix = "sdk-"
        end
        return version:startswith("v") and version or prefix .. version:gsub("%+", ".")
    end})
    add_urls("https://github.com/KhronosGroup/Vulkan-Utility-Libraries.git", {alias = "git"})

    -- when adding a new sdk version, please ensure vulkan-headers, vulkan-hpp, vulkan-loader, vulkan-tools, vulkan-validationlayers, vulkan-utility-libraries, spirv-headers, spirv-reflect, spirv-tools, glslang and volk packages are updated simultaneously
    add_versions("archive:1.4.309+0", "d888151924c2ec0a0a852d2c7d6c2262362f535513efc2a3a413cc2071b551d8")
    add_versions("archive:1.3.283+0", "ac8d5e943e2477c142245a3b835a14efb9c62d617f7ba7a3712ec21080c66df2")
    add_versions("archive:1.3.280+0", "075e13f2fdeeca3bb6fb39155c8cc345cf216ab93661549b1a33368aa28a9dea")
    add_versions("archive:1.3.275+0", "96d3ec7bda7b6e9fabbb471c570104a7b1cb56928d097dd0441c96129468b888")
    add_versions("archive:1.3.268+0", "990de84b66094b647ae420ba13356b79d69e1c6f95532f40466457d51a9d127d")

    add_versions("git:1.4.309+0", "vulkan-sdk-1.4.309.0")
    add_versions("git:1.3.283+0", "vulkan-sdk-1.3.283.0")
    add_versions("git:1.3.280+0", "vulkan-sdk-1.3.280.0")
    add_versions("git:1.3.275+0", "vulkan-sdk-1.3.275.0")
    add_versions("git:1.3.268+0", "vulkan-sdk-1.3.268.0")

    if is_plat("windows") then
        add_syslinks("advapi32")
    end

    add_deps("cmake")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::vulkan-utility-libraries")
    elseif is_plat("linux") then
        add_extsources("apt::vulkan-utility-libraries-dev", "pacman::vulkan-utility-libraries")
    elseif is_plat("macosx") then
        add_extsources("brew::vulkan-utility-libraries")
    end

    on_load(function (package)
        local sdkver = package:version():split("%+")[1]
        package:add("deps", "vulkan-headers " .. sdkver)
    end)

    on_install("windows", "linux", "macosx", "bsd", "mingw", "msys", "cross", function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DUPDATE_DEPS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vkuCreateLayerSettingSet", {includes = "vulkan/layer/vk_layer_settings.h"}))
    end)
