package("hwloc")

    set_homepage("https://www.open-mpi.org/software/hwloc/")
    set_description("Portable Hardware Locality (hwloc)")
    set_license("BSD-3-Clause")

    if is_plat("windows") then
        if is_arch("x86") then
            add_urls("https://download.open-mpi.org/release/hwloc/v$(version).zip", {version = function (version)
                return format("%d.%d/hwloc-win32-build-%s", version:major(), version:minor(), version)
            end})
            add_versions("2.5.0", "0ff33ef99b727a96fcca8fd510e41f73444c5e9ea2b6c475a64a2d9a294f2973")
        elseif is_arch("x64") then
            add_urls("https://download.open-mpi.org/release/hwloc/v$(version).zip", {version = function (version)
                return format("%d.%d/hwloc-win64-build-%s", version:major(), version:minor(), version)
            end})
            add_versions("2.5.0", "b64f5ebe534d1ad57cdd4b18ab4035389b68802a97464c1295005043075309ea")
        end
    else
        add_urls("https://download.open-mpi.org/release/hwloc/v$(version).tar.gz", {version = function (version)
            return format("%d.%d/hwloc-%s", version:major(), version:minor(), version)
        end})
        add_versions("2.5.0", "38aa8102faec302791f6b4f0d23960a3ffa25af3af6af006c64dbecac23f852c")
    end

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    on_install("windows", function (package)
        os.cp("bin", package:installdir())
        os.cp("include", package:installdir())
        os.cp("lib/*|*.a", package:installdir("lib"))
    end)

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("hwloc_get_api_version", {includes = "hwloc.h"}))
    end)
