add_rules("mode.debug", "mode.release")

set_project("gl2ps")
set_version("1.4.2")
set_languages("c99")

option("zlib", {description = "Enable ZLIB compression", default = true})
option("png", {description = "Enable PNG support", default = true})

includes("@builtin/check")

set_configvar("GL2PS_MAJOR_VERSION", 1)
set_configvar("GL2PS_MINOR_VERSION", 4)
set_configvar("GL2PS_PATCH_VERSION", 2)
set_configvar("GL2PS_EXTRA_VERSION", "")
set_configvar("GL2PS_OS", is_plat("macosx") and "MacOSX" or (is_plat("windows", "mingw") and "Windows" or "Linux"))

option("HAVE_VSNPRINTF")
    add_cfuncs("vsnprintf")
    add_cincludes("stdio.h")
option_end()

if not has_config("HAVE_VSNPRINTF") then
    add_defines("HAVE_NO_VSNPRINTF")
end

add_requires("opengl", {optional = true})
add_requires("glut")
if has_config("zlib") then
    add_requires("zlib")
    add_defines("HAVE_ZLIB")
end
if has_config("png") then
    add_requires("libpng")
    add_defines("HAVE_PNG")
end

if is_plat("linux", "macosx") then
    add_syslinks("m")
end

if is_plat("macosx") then
    add_cflags("-Wno-deprecated-declarations")
end

target("gl2ps")
    set_kind("$(kind)")
    add_files("gl2ps.c")
    add_headerfiles("gl2ps.h")
    add_packages("opengl", "glut")

    if is_kind("shared") and is_plat("windows", "cygwin") then
        add_defines("GL2PSDLL", "GL2PSDLL_EXPORTS")
    end
    if is_kind("static") then
        add_defines("GL2PS_STATIC")
    end

    if has_config("zlib") then
        add_packages("zlib")
    end
    if has_config("png") then
        add_packages("libpng")
    end
