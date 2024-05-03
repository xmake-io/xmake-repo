set_project("libmetalink")

option("version", {showmenu = true, default = "0.1.3"})

set_version(get_config("version"))

add_rules("mode.debug", "mode.release")

add_requires("expat")
add_packages("expat")

includes("@builtin/check")

configvar_check_cfuncs("HAVE_MALLOC_H", "malloc", {includes = "malloc.h"})

configvar_check_cincludes("HAVE_INTTYPES_H", "inttypes.h")
configvar_check_cincludes("HAVE_ALLOCA_H", "alloca.h")
configvar_check_cincludes("HAVE_TIME64_H", "time64.h")

target("metalink")
    set_kind("$(kind)")
    add_files("lib/metalink_*.c", "lib/libexpat_metalink_parser.c")

    add_includedirs("lib/includes")
    add_headerfiles("lib/includes/(**.h)")

    add_defines("HAVE_CONFIG_H")
    add_includedirs(os.projectdir())
    set_configdir(os.projectdir())
    add_configfiles("config.h.in")
    add_configfiles("lib/includes/metalink/metalinkver.h.in", {prefixdir = "metalink", pattern = "@(.-)@"})
    add_headerfiles("(metalink/metalinkver.h)")

    if is_plat("windows") then
        add_defines("strncasecmp=_strnicmp")
        add_defines("tzname=_tzname")
        if is_kind("shared") then
            add_rules("utils.symbols.export_all")
        end
    end

    on_config(function (target)
        import("core.base.semver")

        local version = get_config("version")
        if version then
            version = semver.new(version)
            local major = version:major()
            local minor = version:minor()
            local patch = version:patch()
            target:set("configvar", "MAJOR_VERSION", major)
            target:set("configvar", "MINOR_VERSION", minor)
            target:set("configvar", "PATCH_VERSION", patch)
            target:set("configvar", "PACKAGE_VERSION", get_config("version"))
            target:set("configvar", "NUMBER_VERSION", format("0x%02x%02x%02x", tonumber(major), tonumber(minor), tonumber(patch)))
        end

        if target:has_cfuncs("timegm", {includes = "time.h"}) then
            target:add("defines", "HAVE_TIMEGM")
        else
            target:add("files", path.join(os.projectdir(), "lib/timegm.c"))
        end

        if target:has_cfuncs("strptime", {includes = "time.h"}) then
            target:add("defines", "HAVE_STRPTIME")
        else
            target:add("files", path.join(os.projectdir(), "lib/strptime.c"))
        end
    end)
