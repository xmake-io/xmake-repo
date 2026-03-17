package("librttopo")
    set_homepage("https://git.osgeo.org/gitea/rttopo/librttopo")
    set_description("RT Topology Library")
    set_license("GPL-2.0-or-later")

    add_urls("https://gitlab.com/rttopo/rttopo/-/archive/librttopo-$(version)/rttopo-librttopo-$(version).tar.bz2", {alias = "gitlab"})
    add_urls("https://github.com/CGX-GROUP/librttopo.git",
             "https://gitlab.com/rttopo/rttopo", {alias = "git"})

    add_versions("gitlab:1.1.0", "4b28732c0322849c8754751a384ee3596d06ab316dfc57fe9bbe757c82a27efe")

    add_versions("git:1.1.0", "librttopo-1.1.0")

    add_deps("geos")

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk"):config("ndkver")
            assert(ndk and tonumber(ndk) > 22, "package(librttopo) dep(geos) require ndk version > 22")
        end)
    end

    on_install(function (package)
        local geos_ver = assert(package:dep("geos"):version(), "geos version not found")
        os.touch("src/rttopo_config.h")
        io.writefile("xmake.lua", string.format([[
            option("ver", {default = "%s"})
            add_rules("mode.debug", "mode.release")
            add_requires("geos")
            target("rttopo")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_includedirs("headers")
                add_headerfiles("headers/*.h")
                add_defines("RTGEOM_DEBUG_LEVEL=0")
                if has_config("ver") then
                    add_defines("LIBRTGEOM_VERSION=\"" .. get_config("ver") .. "\"")
                    add_defines("RTGEOM_GEOS_VERSION=%s")
                    set_version(get_config("ver"), {soname = true})
                end

                set_configdir("headers")
                add_configfiles("headers/librttopo_geom.h.in", {pattern = "@(SRID_.-)@"})
                -- from https://github.com/conan-io/conan-center-index/blob/fcbc22cd090862c62de0332f9d3aac08620d53ca/recipes/librttopo/all/CMakeLists.txt#L6-L7
                set_configvar("SRID_MAX", "999999")
                set_configvar("SRID_USR_MAX", "998999")

                if is_kind("shared") and is_plat("windows") then
                    add_rules("utils.symbols.export_all")
                end
                if is_plat("linux", "bsd") then
                    add_syslinks("m")
                end
                add_packages("geos")
        ]], package:version_str(), (geos_ver:major() .. geos_ver:minor())))
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("rtgeom_version", {includes = "librttopo.h"}))
    end)
