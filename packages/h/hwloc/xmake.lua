package("hwloc")
    set_homepage("https://www.open-mpi.org/software/hwloc/")
    set_description("Portable Hardware Locality (hwloc)")
    set_license("BSD-3-Clause")

    if is_plat("windows") and is_arch("x86") then
        add_urls("https://download.open-mpi.org/release/hwloc/v$(version).zip", {version = function (version)
            return format("%d.%d/hwloc-win32-build-%s", version:major(), version:minor(), version)
        end})
        add_versions("2.5.0", "0ff33ef99b727a96fcca8fd510e41f73444c5e9ea2b6c475a64a2d9a294f2973")
        add_versions("2.7.1", "217d508f715d42932c6d52e5cf5eb3559d9691d6bb77c34f00b3dcb6517c58e5")
        add_versions("2.12.1", "8c293adbfbeb9ad1295f2d58e8231a7e07938ae7175b4f81ceda78d47274e55f")
    elseif is_plat("windows") and is_arch("x64") then
        add_urls("https://download.open-mpi.org/release/hwloc/v$(version).zip", {version = function (version)
            return format("%d.%d/hwloc-win64-build-%s", version:major(), version:minor(), version)
        end})
        add_versions("2.5.0", "b64f5ebe534d1ad57cdd4b18ab4035389b68802a97464c1295005043075309ea")
        add_versions("2.7.1", "31031eb09f7d8bfaaa069e537ec26374269dddd5b1f1a368c1ed6593849be5b1")
        add_versions("2.12.1", "b48e5407def209bc0b6891becb9f30bb8d1a0c09790085ef56f280e3d164dc4b")
    else
        add_urls("https://download.open-mpi.org/release/hwloc/v$(version).tar.gz", {version = function (version)
            return format("%d.%d/hwloc-%s", version:major(), version:minor(), version)
        end})
        add_versions("2.5.0", "38aa8102faec302791f6b4f0d23960a3ffa25af3af6af006c64dbecac23f852c")
        add_versions("2.7.1", "4cb0a781ed980b03ad8c48beb57407aa67c4b908e45722954b9730379bc7f6d5")
        add_versions("2.12.1", "ffa02c3a308275a9339fbe92add054fac8e9a00cb8fe8c53340094012cb7c633")
    end

    if is_plat("windows") and is_arch("arm64") then
        add_patches(">=2.7.1", "patches/2.12.1/cmake-win-arm64.patch", "2f261838409ed286be114fad061cb7ba8335046c9b33dfd35fd9ca7a61da2a1b")
    end

    add_configs("libxml2", {description = "Use libxml2 instead of minimal XML.", default = false, type = "boolean"})
    add_configs("opencl", {description = "Enable OpenCL support", default = false, type = "boolean"})
    add_configs("cuda", {description = "Enable CUDA support.", default = false, type = "boolean"})
    if is_plat("linux") then
        add_configs("pci", {description = "Enable pciaccess support", default = false, type = "boolean"})
    end
    if is_plat("windows") and is_arch("arm64") then
        add_configs("lstopo", {description = "Build/install lstopo", default = false, type = "boolean"})
        add_configs("tools", {description = "Build/install other hwloc tools", default = false, type = "boolean"})
    end

    if is_plat("linux") then
        add_deps("libudev")
    end
    if is_plat("macosx") then
        add_frameworks("Foundation", "IOKit")
    end

    on_check("windows", function (package)
        -- v2.5.0 have no cmake file.
        if package:is_arch("arm64") and package:version():eq("2.5.0") then
            assert(false, "hwloc version 2.5.0 is not supported on Windows ARM64.")
        end
    end)

    on_load(function (package)
        if package:config("libxml2") then
            package:add("deps", "libxml2")
        end
        if package:config("opencl") then
            package:add("deps", "opencl")
        end
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        if package:is_plat("windows") and package:is_arch("x86", "x64") then
            os.cp("bin", package:installdir())
            os.cp("include", package:installdir())
            os.cp("lib/*|*.a", package:installdir("lib"))
        elseif package:is_plat("windows") then
            local configs = {"-DHWLOC_ENABLE_TESTING=OFF"}
            table.insert(configs, "-DHWLOC_SKIP_LSTOPO=" .. ((not package:config("lstopo")) and "ON" or "OFF"))
            table.insert(configs, "-DHWLOC_SKIP_TOOLS=" .. ((not package:config("tools")) and "ON" or "OFF"))
            table.insert(configs, "-DHWLOC_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DHWLOC_WITH_LIBXML2=" .. (package:config("libxml2") and "ON" or "OFF"))
            table.insert(configs, "-DHWLOC_WITH_OPENCL=" .. (package:config("opencl") and "ON" or "OFF"))
            table.insert(configs, "-DHWLOC_WITH_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
            os.cd("contrib/windows-cmake")
            import("package.tools.cmake").install(package, configs)
        else
            local configs = {}
            table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
            table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
            if package:is_debug() then
                table.insert(configs, "--enable-debug")
            end
            if not package:config("libxml2") then
                table.insert(configs, "--disable-libxml2")
            end
            if not package:config("opencl") then
                table.insert(configs, "--disable-opencl")
            end
            if not package:config("cuda") then
                table.insert(configs, "--disable-cuda")
            end
            if not package:config("pci") then
                table.insert(configs, "--disable-pci")
            end
            import("package.tools.autoconf").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("hwloc_get_api_version", {includes = "hwloc.h"}))
    end)
