set_project("libcroco")
add_rules("mode.debug", "mode.release")

add_requires("glib", "libxml2")

option("installprefix")
    set_default("")
    set_showmenu(true)
option_end()
if has_config("installprefix") then
    local prefix = get_config("installprefix")
    set_configvar("prefix", prefix)
    set_configvar("CROCO_CFLAGS", "-I" .. prefix .. "/include")
    set_configvar("CROCO_LIBS", "-L" .. prefix .. "/lib -lglib-2.0 -pthread -lm -lpcre -lxml2")
end
set_configvar("exec_prefix", "${prefix}")
set_configvar("libdir", "${exec_prefix}/lib")
set_configvar("includedir", "${prefix}/include")
set_configvar("GLIB2_CFLAGS", "")
set_configvar("GLIB2_LIBS", "")
set_configvar("LIBXML2_CFLAGS", "")
set_configvar("LIBXML2_LIBS", "")

local mver = ""
local major_ver = ""
local minor_ver = ""
option("vers")
    set_default("")
    set_showmenu(true)
option_end()
if has_config("vers") then
    set_version(get_config("vers"))
    set_configvar("VERSION", get_config("vers"))
    set_configvar("LIBCROCO_VERSION", get_config("vers"))
    set_configvar("LIBCROCO_VERSION_NUMBER", get_config("vers"))
    local spvers = get_config("vers"):split("%.")
    major_ver = spvers[1] or ""
    minor_ver = spvers[2] or ""
    mver = major_ver .. "." .. minor_ver
    set_configvar("LIBCROCO_MAJOR_VERSION", major_ver)
    set_configvar("LIBCROCO_MINOR_VERSION", minor_ver)
end

set_configvar("G_DISABLE_CHECKS", 0)

target("croco")
    set_basename("croco-" .. mver)
    set_kind("$(kind)")
    add_files("src/*.c")
    add_includedirs("src", {public = true})
    add_packages("glib", "libxml2", {public = true})
    set_configdir("src")
    add_configfiles("src/libcroco-config.h.in", {pattern = "@(.-)@"})
    add_headerfiles("src/*.h", {prefixdir = "libcroco-" .. mver .. "/libcroco"})
target_end()

target("csslint")
    set_basename("csslint-" .. mver)
    set_kind("binary")
    add_deps("croco")
    add_files("csslint/csslint.c")
    set_configdir(".")
    if not is_plat("windows") then
        add_configfiles("croco-config.in", {pattern = "@(.-)@"})
        add_configfiles("libcroco.pc.in", {pattern = "@(.-)@"})
        after_install(function (target)
            os.cp("croco-config", path.join(target:installdir(), "bin", "croco-" .. mver .. "-config"))
            os.cp("libcroco.pc", path.join(target:installdir(), "lib", "pkgconfig", "libcroco-" .. mver .. ".pc"))
        end)
    end
target_end()
