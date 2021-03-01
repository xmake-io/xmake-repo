package("vulkan-validationlayers")

    set_homepage("https://github.com/KhronosGroup/Vulkan-ValidationLayers/")
    set_description("Vulkan Validation Layers")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/Vulkan-ValidationLayers/archive/sdk-$(version).tar.gz", {version = function (version) return version:gsub("%+", ".") end})
    add_versions("1.2.162+0", "80aa9e180b3900598121d7a3ea613665b99aae21bb40268ecafd82df8016c6f5")
    add_versions("1.2.154+0", "8898ab05d0d8dec04fbba03d0ed2e79a1eb5c0382e5c89d4c737b45a6648f7f9")

    add_patches("1.2.154+0", "https://github.com/KhronosGroup/Vulkan-ValidationLayers/commit/9d3ef3258715573b17e8195855c76626600998be.patch", "1fa39483c345fbfb43b925e8410a55e58fa8a9776f9e5443c6e4ec994a554749")

    add_deps("cmake")
    add_deps("glslang", "spirv-headers", "spirv-tools")
    if is_plat("windows") then
        add_syslinks("Advapi32")
    elseif is_plat("linux") then
        add_deps("ninja")
        add_deps("wayland", "libxrandr", "libxcb", "libxkbcommon")
    end

    on_load("windows", "linux", function (package)
        local sdkver = package:version():split("%+")[1]
        package:add("deps", "vulkan-headers " .. sdkver)
    end)

    on_install("windows", "linux", function (package)
        import("package.tools.cmake")

        local envs = cmake.buildenvs(package, {cmake_generator = "Ninja"})
        if package:is_plat("linux") then
            local includes = {}
            local linkdirs = {}
            for _, lib in ipairs({"wayland", "libxrandr", "libxcb", "libxkbcommon"}) do
                local fetchinfo = package:dep(lib):fetch()
                for _, dir in ipairs(fetchinfo.sysincludedirs or fetchinfo.includedirs) do
                    table.insert(includes, dir)
                end
                for _, dir in ipairs(fetchinfo.linkdirs) do
                    table.insert(linkdirs, dir)
                end
            end
            envs.CPLUS_INCLUDE_PATH = (envs.CPLUS_INCLUDE_PATH or "") .. path.envsep() .. path.joinenv(table.unique(includes))
            envs.LD_LIBRARY_PATH = (envs.LD_LIBRARY_PATH or "") .. path.envsep() .. path.joinenv(table.unique(linkdirs))
        end

        local configs = {"-DBUILD_TESTS=OFF"}
        local vulkan_headers = package:dep("vulkan-headers")
        local glslang = package:dep("glslang")
        local spirv_headers = package:dep("spirv-headers")
        local spirv_tools = package:dep("spirv-tools")
        table.insert(configs, "-DVULKAN_HEADERS_INSTALL_DIR=" .. vulkan_headers:installdir())
        table.insert(configs, "-DGLSLANG_INSTALL_DIR=" .. glslang:installdir())
        table.insert(configs, "-DSPIRV_HEADERS_INSTALL_DIR=" .. spirv_headers:installdir())
        table.insert(configs, "-DSPIRV_TOOLS_INSTALL_DIR=" .. spirv_tools:installdir())

        if package:is_plat("windows") then
            cmake.install(package, configs, {buildir = os.tmpfile() .. ".dir"})
        elseif is_plat("linux") then
            cmake.install(package, configs, {buildir = os.tmpfile() .. ".dir", cmake_generator = "Ninja", envs = envs})
        end
        os.mv("layers", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("getLayerOption", {includes = "layers/vk_layer_config.h"}))
    end)
