set_project("pkg-config")

add_rules("mode.debug", "mode.release")

set_configvar("PACKAGE", "pkg-config")
set_configvar("PACKAGE_NAME", "pkg-config")
set_configvar("PACKAGE_TARNAME", "pkg-config")
set_configvar("PACKAGE_BUGREPORT", "https://bugs.freedesktop.org/enter_bug.cgi?product=pkg-config")
set_configvar("PACKAGE_URL", "")

option("vers")
    set_default("")
    set_showmenu(true)
option_end()
if has_config("vers") then
    set_version(get_config("vers"))
    set_configvar("VERSION", get_config("vers"))
    set_configvar("PACKAGE_VERSION", get_config("vers"))
    set_configvar("PACKAGE_STRING", "gettext-runtime " .. get_config("vers"))
end

option("relocatable")
    set_default(true)
    set_showmenu(true)
option_end()
if has_config("relocatable") then
    add_defines("ENABLE_RELOCATABLE=1")
    set_configvar("ENABLE_RELOCATABLE", 1)
end

option("enable-define-prefix")
    set_default(false)
    set_showmenu(true)
option_end()
if has_config("enable-define-prefix") then
    add_defines("ENABLE_DEFINE_PREFIX=1")
    set_configvar("ENABLE_DEFINE_PREFIX", 1)
end

option("enable-indirect-deps")
    set_default(false)
    set_showmenu(true)
option_end()
if has_config("enable-indirect-deps") then
    add_defines("ENABLE_INDIRECT_DEPS=1")
    set_configvar("ENABLE_INDIRECT_DEPS", 1)
else
    add_defines("ENABLE_INDIRECT_DEPS=0")
    set_configvar("ENABLE_INDIRECT_DEPS", 0)
end

includes("check_cincludes.lua")

configvar_check_cincludes("HAVE_DIRENT_H", "dirent.h")
configvar_check_cincludes("HAVE_MALLOC_H", "malloc.h")
configvar_check_cincludes("HAVE_SYS_WAIT_H", "sys/wait.h")
configvar_check_cincludes("HAVE_UNISTD_H", "unistd.h")

add_requires("glib")
target("pkg-config")
    set_kind("binary")
    add_packages("glib")
    add_defines("HAVE_CONFIG_H")
    if is_plat("windows", "mingw") then
        add_defines("PKG_CONFIG_PC_PATH", "\"$(subst /,\\/,$(pc_path))\"")
        add_defines("PKG_CONFIG_SYSTEM_INCLUDE_PATH", "\"$(subst /,\\/,$(system_include_path))\"")
        add_defines("PKG_CONFIG_SYSTEM_LIBRARY_PATH", "\"$(subst /,\\/,$(system_library_path))\"")
    else
        add_defines("PKG_CONFIG_PC_PATH", "\"$(pc_path)\"")
        add_defines("PKG_CONFIG_SYSTEM_INCLUDE_PATH", "\"$(system_include_path)\"")
        add_defines("PKG_CONFIG_SYSTEM_LIBRARY_PATH", "\"$(system_library_path)\"")
    end
    set_configdir("$(projectdir)")
    add_configfiles("config.h.in", {filename = "config.h"})
    add_files("pkg.c",
              "parse.c",
              "rpmvercmp.c",
              "main.c")
target_end()
