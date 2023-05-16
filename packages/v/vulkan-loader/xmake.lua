package("vulkan-loader")

    set_homepage("https://github.com/KhronosGroup/Vulkan-Loader")
    set_description("This project provides the Khronos official Vulkan ICD desktop loader for Windows, Linux, and MacOS.")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/Vulkan-Loader/archive/sdk-$(version).tar.gz", {version = function (version) return version:gsub("%+", ".") end})
    add_versions("1.3.246+1", "5ffb79b83ec539233ee793dd3c50aa241bd9bd67103d45d3f4b657f1620b7553")
    add_versions("1.3.239+0", "fa2078408793b2173f174173a8784de56b6bbfbcb5fb958a07e46ef126c7eada")
    add_versions("1.3.236+0", "157d2230b50bb5be3ef9b9467aa90d1c109d5f188a49b11f741246d7ca583bf3")
    add_versions("1.3.231+1", "5226fbc6a90e4405200c8cfdd5733d5e0c6a64e64dcc614c485ea06e03d66578")
    add_versions("1.2.198+0", "7d5d56296dcd88af84ed0fde969038370cac8600c4ef7e328788b7422d9025bb")
    add_versions("1.2.189+1", "1d9f539154d37cea0ca336341c3b25e73d5a5320f2f9c9c55f8309422fe6ec3c")
    add_versions("1.2.182+0", "7088fb6922a3af41efd0499b8e66e971164da1e583410d29f801f991a31b180c")
    add_versions("1.2.162+0", "f8f5ec2485e7fdba3f58c1cde5a25145ece1c6a686c91ba4016b28c0af3f21dd")
    add_versions("1.2.154+1", "889e45f7175d915dd0d702013b8021192e181d20f2ad4021c94006088f1edfe5")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    if is_plat("linux") then
        add_extsources("apt::libvulkan-dev", "pacman::vulkan-icd-loader")
        add_deps("wayland", "libxrandr", "libxrender", "libxcb", "libxkbcommon")
    end

    on_load("windows", "linux", "macosx", function (package)
        local sdkver = package:version():split("%+")[1]
        package:add("deps", "vulkan-headers " .. sdkver)
        if not package.is_built or package:is_built() then
            package:add("deps", "cmake")
        end
        if package:is_plat("macosx") then
            package:add("links", "vulkan")
        end
    end)

    on_fetch("macosx", function (package, opt)
        if opt.system then
            import("lib.detect.find_path")
            local libdir = find_path("libvulkan.dylib", "~/VulkanSDK/*/macOS/lib")
            local includedir = find_path("vulkan/vulkan.h", "~/VulkanSDK/*/macOS/include")
            if libdir and includedir then
                return {linkdirs = libdir, links = "vulkan", includedirs = includedir}
            end
        end
    end)

    on_install("windows|x86", "windows|x64", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTS=OFF"}
        local vulkan_headers = package:dep("vulkan-headers")
        table.insert(configs, "-DVULKAN_HEADERS_INSTALL_DIR=" .. vulkan_headers:installdir())
        if package:is_plat("linux") then
            import("package.tools.cmake").install(package, configs, {packagedeps = {"wayland", "libxrandr", "libxrender", "libxcb", "libxkbcommon"}})
        else
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vkGetDeviceProcAddr", {includes = "vulkan/vulkan_core.h"}))
    end)
