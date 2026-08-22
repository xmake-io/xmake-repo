package("vulkan-validationlayers")
    set_homepage("https://github.com/KhronosGroup/Vulkan-ValidationLayers/")
    set_description("Vulkan Validation Layers")
    set_license("Apache-2.0")

    -- when adding a new sdk version, please ensure vulkan-headers, vulkan-hpp, vulkan-loader, vulkan-tools, vulkan-validationlayers, vulkan-utility-libraries, spirv-headers, spirv-reflect, spirv-tools, glslang and volk packages are updated simultaneously

    if is_plat("android") then
        add_urls("https://github.com/KhronosGroup/Vulkan-ValidationLayers/releases/download/$(version).tar.gz", {version = function (version)
            local versionLoc = version:gsub("%+", ".")
            if version:gt("1.3.268+0") then
                return "vulkan-sdk-" .. versionLoc .. "/android-binaries-" .. versionLoc
            elseif version:gt("1.3.261+1") then
                return "vulkan-sdk-" .. versionLoc .. "/android-binaries-vulkan-sdk-" .. versionLoc
            elseif version:gt("1.3.250+1") then
                return "sdk-" .. versionLoc .. "/android-binaries-sdk-" .. versionLoc
            else
                return "sdk-" .. versionLoc .. "/android-binaries-" .. versionLoc
            end
        end})

        add_versions("1.4.335+0", "73a44912edc44247d22509ff2222ef8823d42bd58b72273ca5eae8a1c6d3c7c5")
        add_versions("1.4.309+0", "6483ee30edcba3bb05e0ab3569dee632fd4532c190fef780e9ff038391c2edec")
        add_versions("1.3.290+0", "eb26b4bf1f031e57d1624c53d489279076b893b0383fddccc79de7ee2caaa128")
        add_versions("1.3.275+0", "6e22fb13601c1e780c44a17497a3c999cc5207e52a09819e7c32ecd8439eff7a")
        add_versions("1.2.198+0", "5436e974d6b3133b3454edf1910f76b9f869db8bbe086859b2abe32fdb539cbc")
        add_versions("1.2.189+1", "b3e69b60a67a17b023825f9eb0ce1aef22e6b59d095afa204d883a9ce3d81021")
    else
        add_urls("https://github.com/KhronosGroup/Vulkan-ValidationLayers/archive/refs/tags/$(version).tar.gz", {version = function (version)
            local prefix = ""
            if version:gt("1.3.261+1") then
                prefix = "vulkan-sdk-"
            elseif version:ge("1.3.226") then
                prefix = "sdk-"
            end
            return version:startswith("v") and version or prefix .. version:gsub("%+", ".")
        end})

        add_versions("1.4.335+0", "464f754abdebef13c342e18861eab87be0ecc36cb1c257f6b2ddfa10afb8401a")
        add_versions("1.4.309+0", "56eb7b70c0ebf3e6b7def7723617a71bd01ca1497ab8dec542e1e4eadf6e07d7")
        add_versions("1.3.290+0", "59be2c0a5bdbfdbdebdcda48bd65ffa3b219f681c73a90fc683cd4708c1b79de")
        add_versions("1.3.275+0", "acfd84039109220129624b0ecb69980bbc3a858978c62b556dbe16efd0f26755")
        add_versions("1.2.198+0", "4a70cc5da26baf873fcf69b081eeeda545515dd66e5904f18fee32b4d275593a")
        add_versions("1.2.189+1", "d169ae71ae3ba12159df355b58f86f5635062c695d1deac9b97d5653561d517d")
        add_versions("1.2.182+0", "e88492143c8b08154807e7ead0ac784365b14464bb5016c2800cbff176ff61e7")
        add_versions("1.2.162+0", "80aa9e180b3900598121d7a3ea613665b99aae21bb40268ecafd82df8016c6f5")
        add_versions("1.2.154+0", "8898ab05d0d8dec04fbba03d0ed2e79a1eb5c0382e5c89d4c737b45a6648f7f9")

        add_patches("1.2.154+0", "https://github.com/KhronosGroup/Vulkan-ValidationLayers/commit/9d3ef3258715573b17e8195855c76626600998be.patch", "1fa39483c345fbfb43b925e8410a55e58fa8a9776f9e5443c6e4ec994a554749")

        add_deps("cmake")
        add_deps("glslang", "spirv-headers", "spirv-tools")
        
        if is_plat("windows") then
            add_syslinks("Advapi32")
        end

        if is_plat("mingw") and is_subhost("msys") then
            add_extsources("pacman::vulkan-validation-layers")   
        elseif is_plat("linux") then
            add_extsources("apt::vulkan-validationlayers-dev", "pacman::vulkan-validation-layers")
            add_deps("ninja")
            add_deps("wayland", "libxrandr", "libxrender", "libxcb", "libxkbcommon")
        elseif is_plat("macosx") then
            add_extsources("brew::vulkan-validationlayers")
        end
    end

    on_load("windows", "linux", function (package)
        local sdkver = package:version():split("%+")[1]
        package:add("deps", "vulkan-headers " .. sdkver)

        if package:version():ge("1.3.275") then
            package:add("deps", "vulkan-utility-libraries " .. sdkver)
        end

        package:addenv("VK_ADD_LAYER_PATH", package:is_plat("windows") and "bin" or "lib")
        package:mark_as_pathenv("VK_ADD_LAYER_PATH")
    end)

    on_install("windows", "linux", function (package)
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
            envs.CPLUS_INCLUDE_PATH = (envs.CPLUS_INCLUDE_PATH or "") .. path.envsep() .. path.joinenv(table.unique(includes))
            envs.LD_LIBRARY_PATH = (envs.LD_LIBRARY_PATH or "") .. path.envsep() .. path.joinenv(table.unique(linkdirs))
        end

        local configs = {"-DBUILD_TESTS=OFF"}
        table.insert(configs, "-DVULKAN_HEADERS_INSTALL_DIR=" .. package:dep("vulkan-headers"):installdir())
        table.insert(configs, "-DGLSLANG_INSTALL_DIR=" .. package:dep("glslang"):installdir())
        table.insert(configs, "-DSPIRV_HEADERS_INSTALL_DIR=" .. package:dep("spirv-headers"):installdir())
        table.insert(configs, "-DSPIRV_TOOLS_INSTALL_DIR=" .. package:dep("spirv-tools"):installdir())

        if package:is_plat("windows") then
            cmake.install(package, configs, {buildir = os.tmpfile() .. ".dir"})
        elseif package:is_plat("linux") then
            cmake.install(package, configs, {buildir = os.tmpfile() .. ".dir", cmake_generator = "Ninja", envs = envs})
            os.cp(package:installdir("share/vulkan/explicit_layer.d/VkLayer_khronos_validation.json"), package:installdir("lib"))
        end
        os.mv("layers", package:installdir("include"))
    end)

    on_install("android", function (package)
        os.cp("*", package:installdir("lib"))
    end)

    on_test(function (package)
        if package:is_plat("android") then
            assert(os.isfile(path.join(package:installdir("lib"), "x86_64", "libVkLayer_khronos_validation.so")))
            assert(os.isfile(path.join(package:installdir("lib"), "x86", "libVkLayer_khronos_validation.so")))
            assert(os.isfile(path.join(package:installdir("lib"), "armeabi-v7a", "libVkLayer_khronos_validation.so")))
            assert(os.isfile(path.join(package:installdir("lib"), "arm64-v8a", "libVkLayer_khronos_validation.so")))
        elseif package:is_plat("windows") then
            assert(os.isfile(path.join(package:installdir("bin"), "VkLayer_khronos_validation.dll")))
            assert(os.isfile(path.join(package:installdir("bin"), "VkLayer_khronos_validation.json")))
        elseif package:is_plat("linux") then
            assert(os.isfile(path.join(package:installdir("lib"), "libVkLayer_khronos_validation.so")))
            assert(os.isfile(path.join(package:installdir("lib"), "VkLayer_khronos_validation.json")))
        end
    end)
