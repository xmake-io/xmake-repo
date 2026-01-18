package("vulkan-tools")
    set_kind("binary")
    set_homepage("https://github.com/KhronosGroup/Vulkan-Tools")
    set_description("Vulkan Utilities and Tools")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/Vulkan-Tools/archive/refs/tags/$(version).tar.gz", {alias = "archive", version = function (version)
        local prefix
        if version:gt("1.3.261+1") then
            prefix = "vulkan-sdk-"
        else
            prefix = "sdk-"
        end
        return prefix .. version:gsub("%+", ".")
    end})
    add_urls("https://github.com/KhronosGroup/Vulkan-Tools.git", {alias = "git"})

    -- when adding a new sdk version, please ensure vulkan-headers, vulkan-hpp, vulkan-loader, vulkan-tools, vulkan-validationlayers, vulkan-utility-libraries, spirv-headers, spirv-reflect, spirv-tools, glslang and volk packages are updated simultaneously
    add_versions("archive:1.4.335+0", "85bf51a54271c87925711f7159ea66cc6c5abf6afd5f2bbf452d444fd7deccf3")
    add_versions("archive:1.4.309+0", "d854ff4324b519ff4a1cf5d9e9c333e5244ea7870fad6eadd73efd7b04aedcb0")
    add_versions("archive:1.2.198+0", "06e174bca7834df73dc6ce3c2a72ab3bc34b63e16fdb9a486bf1315f02768032")
    add_versions("archive:1.2.189+1", "ef5db0934ff7192657bbfc675f6e3e1ee009f2ad34aab915d2bd9993a59add81")
    add_versions("archive:1.2.162+0", "8324a6dfd1bc20d4fad45c4ea56357d8354fc03e3e4529d0a4919f124d9e6106")
    add_versions("archive:1.2.154+0", "c7d66ec1f5fe5c0a13e487fe5c6eefd3a954522c0b05f06bd2ae41792aeea272")

    add_versions("git:1.4.335+0", "vulkan-sdk-1.4.335.0")
    add_versions("git:1.4.309+0", "vulkan-sdk-1.4.309.0")
    add_versions("git:1.2.198+0", "sdk-1.2.198.0")
    add_versions("git:1.2.189+1", "sdk-1.2.189.1")
    add_versions("git:1.2.162+0", "sdk-1.2.162.0")
    add_versions("git:1.2.154+0", "sdk-1.2.154.0")

    add_deps("glslang")

    if is_plat("linux") then
        add_extsources("apt::vulkan-tools", "pacman::vulkan-tools")
        add_deps("wayland", "libxrandr", "libxcb", "libxkbcommon")
    end

    on_load("windows|x64", "linux", function (package)
        local sdkver = package:version():split("%+")[1]
        package:add("deps", "vulkan-headers " .. sdkver)
        package:add("deps", "vulkan-loader " .. sdkver)
        if package:version():ge("1.3.271") then
            package:add("deps", "volk " .. sdkver)
        end
        if not package.is_built or package:is_built() then
            package:add("deps", "cmake", "ninja")
        end
        if package:is_plat("linux") then
            package:add("deps", "libx11", "libxcb", "libxrandr", "libxrender", "wayland")
        end
    end)

    on_install("windows|x64", "linux", function (package)
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

        package:addenv("PATH", "bin")
        io.replace(path.join("icd", "CMakeLists.txt"), "copy ${src_json} ${dst_json}", "${CMAKE_COMMAND} -E copy ${src_json} ${dst_json}", {plain = true})
        local configs = {}
        local vulkan_headers = package:dep("vulkan-headers")
        local vulkan_loader = package:dep("vulkan-loader")
        local glslang = package:dep("glslang")
        table.insert(configs, "-DBUILD_CUBE=OFF")
        table.insert(configs, "-DBUILD_TESTS=OFF")
        table.insert(configs, "-DBUILD_WERROR=OFF")
        table.insert(configs, "-DTOOLS_CODEGEN=OFF")
        table.insert(configs, "-DVULKAN_HEADERS_INSTALL_DIR=" .. vulkan_headers:installdir())
        table.insert(configs, "-DVULKAN_LOADER_INSTALL_DIR=" .. vulkan_loader:installdir())
        table.insert(configs, "-DGLSLANG_INSTALL_DIR=" .. glslang:installdir())
        local opt = {cmake_generator = "Ninja", envs = envs}
        if package:is_plat("linux") then
            opt.packagedeps = {"libx11", "libxcb", "libxrandr", "libxrender", "wayland"}
        end
        cmake.install(package, configs, opt)
    end)

    on_test(function (package)
        local boostdep = package:installdir("bin/vulkaninfo")
        if is_host("windows") then
            boostdep = boostdep .. ".exe"
        end
        assert(os.isexec(boostdep), "vulkaninfo not found!")
    end)
