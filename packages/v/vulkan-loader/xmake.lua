package("vulkan-loader")

    set_homepage("https://github.com/KhronosGroup/Vulkan-Loader")
    set_description("This project provides the Khronos official Vulkan ICD desktop loader for Windows, Linux, and MacOS.")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/Vulkan-Loader/archive/sdk-$(version).tar.gz", {version = function (version) return version:gsub("%+", ".") end})
    add_versions("1.3.224+1", "4d54b1489faa42d309e5d1e34d6655a9587ad988e99bb2a2ce0e357844f2cb2d")
    add_versions("1.2.198+0", "7d5d56296dcd88af84ed0fde969038370cac8600c4ef7e328788b7422d9025bb")
    add_versions("1.2.189+1", "1d9f539154d37cea0ca336341c3b25e73d5a5320f2f9c9c55f8309422fe6ec3c")
    add_versions("1.2.182+0", "7088fb6922a3af41efd0499b8e66e971164da1e583410d29f801f991a31b180c")
    add_versions("1.2.162+0", "f8f5ec2485e7fdba3f58c1cde5a25145ece1c6a686c91ba4016b28c0af3f21dd")
    add_versions("1.2.154+1", "889e45f7175d915dd0d702013b8021192e181d20f2ad4021c94006088f1edfe5")

    if is_plat("linux") then
        add_extsources("apt::libvulkan-dev", "pacman::vulkan-icd-loader")
        add_deps("wayland", "libxrandr", "libxrender", "libxcb", "libxkbcommon")
    end

    on_load("windows", "linux", "macosx", function (package)
        local sdkver = package:version():split("%+")[1]
        package:add("deps", "vulkan-headers " .. sdkver)
        if not package.is_built or package:is_built() then
            package:add("deps", "cmake", "ninja")
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

    on_install("windows", "linux", "macosx", function (package)
        import("package.tools.cmake")
        local envs = cmake.buildenvs(package, {cmake_generator = "Ninja"})
        if package:is_plat("linux") then
            local includes = {}
            local linkdirs = {}
            for _, lib in ipairs({"wayland", "libxrandr", "libxrender", "libxcb", "libxkbcommon"}) do
                local fetchinfo = package:dep(lib):fetch()
                for _, dir in ipairs(fetchinfo.sysincludedirs or fetchinfo.includedirs) do
                    table.insert(includes, dir)
                end
                for _, dir in ipairs(fetchinfo.linkdirs) do
                    table.insert(linkdirs, dir)
                end
            end
            envs.C_INCLUDE_PATH = (envs.C_INCLUDE_PATH or "") .. path.envsep() .. path.joinenv(table.unique(includes))
            envs.LD_LIBRARY_PATH = (envs.LD_LIBRARY_PATH or "") .. path.envsep() .. path.joinenv(table.unique(linkdirs))
        end

        local configs = {"-DBUILD_TESTS=OFF"}
        local vulkan_headers = package:dep("vulkan-headers")
        table.insert(configs, "-DVULKAN_HEADERS_INSTALL_DIR=" .. vulkan_headers:installdir())
        -- fix pdb issue, cannot open program database v140.pdb
        if package:is_plat("windows") then
            os.mkdir("build/loader/pdb")
            os.mkdir("build/cube/pdb")
            os.mkdir("build/vulkaninfo/pdb")
        end
        cmake.install(package, configs, {cmake_generator = "Ninja", envs = envs, buildir = "build"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vkGetDeviceProcAddr", {includes = "vulkan/vulkan_core.h"}))
    end)
