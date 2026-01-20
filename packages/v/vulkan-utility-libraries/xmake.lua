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
    add_versions("archive:1.4.335+0", "df27b66cfabf7d890398274ffda16b89711d41647fc8e0e8bb419994457948f9")
    add_versions("archive:1.4.309+0", "92e3b842d61965ccab1de04f154eeedef23f895104330e8237055a9ee2feed62")
    add_versions("archive:1.3.283+0", "765a2bb9767e77cd168dfac870533d60b7e8e0031a0738bbe060ca0d4c4e7a03")
    add_versions("archive:1.3.280+0", "075e13f2fdeeca3bb6fb39155c8cc345cf216ab93661549b1a33368aa28a9dea")
    add_versions("archive:1.3.275+0", "37d6b0771e1e351916f4d642cc12c696a3afffea6c47f91c97372287974e2bd8")
    add_versions("archive:1.3.268+0", "0352a6a9a703a969a805e0d6498e013cba2dc7091cc2013b7c89b1a21f61e3f8")

    add_versions("git:1.4.335+0", "vulkan-sdk-1.4.335.0")
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
