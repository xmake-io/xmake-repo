package("vulkan-tools")

    set_kind("binary")
    set_homepage("https://github.com/KhronosGroup/Vulkan-Tools")
    set_description("Vulkan Utilities and Tools")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/Vulkan-Tools/archive/sdk-$(version).tar.gz", {version = function (version) return version:gsub("%+", ".") end})
    add_versions("1.3.224+1", "fa88ab7a542cc3ec05d22316ffedce7c058350efe79ec5e019c405ab268d17a0")
    add_versions("1.2.198+0", "06e174bca7834df73dc6ce3c2a72ab3bc34b63e16fdb9a486bf1315f02768032")
    add_versions("1.2.189+1", "ef5db0934ff7192657bbfc675f6e3e1ee009f2ad34aab915d2bd9993a59add81")
    add_versions("1.2.162+0", "8324a6dfd1bc20d4fad45c4ea56357d8354fc03e3e4529d0a4919f124d9e6106")
    add_versions("1.2.154+0", "c7d66ec1f5fe5c0a13e487fe5c6eefd3a954522c0b05f06bd2ae41792aeea272")

    add_deps("glslang")
    if is_plat("linux") then
        add_extsources("apt::vulkan-tools", "pacman::vulkan-tools")
        add_deps("wayland", "libxrandr", "libxcb", "libxau", "libxdmcp", "libxkbcommon")
    end

    on_load("windows|x64", "linux", function (package)
        local sdkver = package:version():split("%+")[1]
        package:add("deps", "vulkan-headers " .. sdkver)
        package:add("deps", "vulkan-loader " .. sdkver)
        if not package.is_built or package:is_built() then
            package:add("deps", "cmake", "ninja")
        end
    end)

    on_install("windows|x64", "linux", function (package)
        import("package.tools.cmake")
        local envs = cmake.buildenvs(package, {cmake_generator = "Ninja"})
        if package:is_plat("linux") then
            local includes = {}
            local linkdirs = {}
            for _, lib in ipairs({"wayland", "libxrandr", "libxcb", "libxau", "libxdmcp", "libxkbcommon"}) do
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
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DVULKAN_HEADERS_INSTALL_DIR=" .. vulkan_headers:installdir())
        table.insert(configs, "-DVULKAN_LOADER_INSTALL_DIR=" .. vulkan_loader:installdir())
        table.insert(configs, "-DGLSLANG_INSTALL_DIR=" .. glslang:installdir())
        local packagedeps
        if package:is_plat("linux") then
            packagedeps = {"wayland", "libxrandr", "libxcb", "libxau", "libxdmcp", "libxkbcommon"}
            io.replace("cube/CMakeLists.txt", "${XCB_LIBRARIES}", "", {plain = true})
            io.replace("vulkaninfo/CMakeLists.txt", "${XCB_LIBRARIES}", "", {plain = true})
        end
        -- fix pdb issue, cannot open program database v140.pdb
        if package:is_plat("windows") then
            os.mkdir("build/vulkaninfo/pdb")
            os.mkdir("build/icd/pdb")
            os.mkdir("build/cube/pdb")
        end
        cmake.install(package, configs, {cmake_generator = "Ninja", envs = envs, packagedeps = packagedeps, buildir = "build"})
    end)

    on_test(function (package)
        os.vrun("vulkaninfo --summary")
    end)
