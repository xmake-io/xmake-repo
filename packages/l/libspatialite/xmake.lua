package("libspatialite")
    set_homepage("https://git.osgeo.org/gitea/rttopo/librttopo")
    set_description("https://www.gaia-gis.it/fossil/libspatialite/index")
    set_license("MPL-1.1")

    add_urls("https://www.gaia-gis.it/gaia-sins/libspatialite-sources/libspatialite-$(version).tar.gz")

    add_versions("5.1.0", "43be2dd349daffe016dd1400c5d11285828c22fea35ca5109f21f3ed50605080")

    add_configs("mathsql",      {description = "enables SQL math functions", default = false, type = "boolean"})
    add_configs("geocallbacks", {description = "enables SQL math functions", default = false, type = "boolean"})
    add_configs("knn",          {description = "enables SQL math functions", default = false, type = "boolean"})
    add_configs("proj",         {description = "enables PROJ.4 inclusion", default = false, type = "boolean"})
    add_configs("iconv",        {description = "enables ICONV inclusion", default = false, type = "boolean"})
    add_configs("freexl",       {description = "enables FreeXL inclusion", default = false, type = "boolean"})
    add_configs("epsg",         {description = "enables full EPSG dataset support", default = false, type = "boolean"})
    add_configs("geos",         {description = "enables GEOS inclusion", default = false, type = "boolean"})
    add_configs("gcp",          {description = "enables Control Points (from Grass GIS)", default = false, type = "boolean"})
    add_configs("rttopo",       {description = "enables RTTOPO support", default = false, type = "boolean"})
    add_configs("libxml2",      {description = "enables libxml2 inclusion", default = false, type = "boolean"})
    add_configs("minizip",      {description = "enables MiniZIP inclusion", default = false, type = "boolean"})
    add_configs("geopackage",   {description = "enables GeoPackage support", default = false, type = "boolean"})

    local deps = {
        "proj",
        "iconv",
        "freexl",
        "geos",
        "rttopo",
        "libxml2",
        "minizip",
    }
    add_deps("sqlite3", "zlib")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk"):config("ndkver")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk and tonumber(ndk) > 22, "package(librttopo) dep(geos) require ndk version > 22")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 23, "package(freexl) dep(minizip) require ndk api level >= 23")
        end)
    end

    on_load(function (package)
        for _, dep in ipairs(deps) do
            if package:config(dep) then
                if dep == "rttopo" then
                    package:add("deps", "librttopo")
                else
                    package:add("deps", dep)
                end
            end
        end
    end)

    on_install("@!windows", function (package)
        io.replace("Makefile.am", "SUBDIRS = src test $(EXAMPLES)", "SUBDIRS = src", {plain = true})
        io.replace("configure.ac", "AC_MSG_ERROR([the user-specified geos-config", "echo # ", {plain = true})
        io.replace("configure.ac", "AC_CHECK_HEADERS([geos_c.h", "# ", {plain = true})
        io.replace("configure.ac", "AC_SEARCH_LIBS(GEOSCoveredBy", "# ", {plain = true})

        local configs = {
            "--disable-gcov",
            "--disable-examples",
            "--disable-module-only",
        }
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-mathsql=" .. (package:config("mathsql") and "yes" or "no"))
        table.insert(configs, "--enable-geocallbacks=" .. (package:config("geocallbacks") and "yes" or "no"))
        table.insert(configs, "--enable-knn=" .. (package:config("knn") and "yes" or "no"))
        table.insert(configs, "--enable-proj=" .. (package:config("proj") and "yes" or "no"))
        table.insert(configs, "--enable-iconv=" .. (package:config("iconv") and "yes" or "no"))
        table.insert(configs, "--enable-freexl=" .. (package:config("freexl") and "yes" or "no"))
        table.insert(configs, "--enable-epsg=" .. (package:config("epsg") and "yes" or "no"))
        table.insert(configs, "--enable-geos=" .. (package:config("geos") and "yes" or "no"))
        table.insert(configs, "--enable-gcp=" .. (package:config("gcp") and "yes" or "no"))
        table.insert(configs, "--enable-rttopo=" .. (package:config("rttopo") and "yes" or "no"))
        table.insert(configs, "--enable-libxml2=" .. (package:config("libxml2") and "yes" or "no"))
        table.insert(configs, "--enable-minizip=" .. (package:config("minizip") and "yes" or "no"))
        table.insert(configs, "--enable-geopackage=" .. (package:config("geopackage") and "yes" or "no"))

        local opt = {
            packagedeps = {"sqlite3", "zlib"}
        }
        for _, dep in ipairs(deps) do
            if package:config(dep) then
                if dep == "rttopo" then
                    table.insert(opt.packagedeps, "librttopo")
                else
                    table.insert(opt.packagedeps, dep)
                end
            end
        end
        import("package.tools.autoconf").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("spatialite_initialize", {includes = {"sqlite3.h", "spatialite.h"}}))
    end)
