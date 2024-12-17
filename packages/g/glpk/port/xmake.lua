option("dl", {default = nil, type = "string", values = {"ltdl", "dlfcn"}})
option("gmp", {default = false})
option("mysql", {default = false})
option("odbc", {default = false})

add_rules("mode.debug", "mode.release")

add_requires("zlib")

local dl = get_config("dl")
if dl == "ltdl" then
    add_requires("libtool", {kind = "library"})
    add_packages("libtool")
    add_defines("HAVE_LTDL")
elseif dl == "dlfcn" then
    if is_plat("linux", "bsd") then
        add_syslinks("dl")
    end
    add_defines("HAVE_DLFCN")
end

if has_config("gmp") then
    add_requires("gmp")
    add_packages("gmp")
    add_defines("HAVE_GMP")
end

if has_config("mysql") then
    add_requires("mysql")
    -- TODO
    -- add_defines("MYSQL_DLNAME=" .. mysql shared link name)
end

includes("@builtin/check")

configvar_check_cincludes("HAVE_SYS_TIME_H", "sys/time.h")
configvar_check_cfuncs("HAVE_GETTIMEOFDAY", "gettimeofday", {includes = "time.h"})

target("glpk")
    set_kind("$(kind)")
    add_files("src/**.c|zlib/*.c")
    add_includedirs("src", {public = true})
    add_includedirs(
        "src/amd",
        "src/api",
        "src/bflib",
        "src/colamd",
        "src/draft",
        "src/env",
        "src/intopt",
        "src/minisat",
        "src/misc",
        "src/mpl",
        "src/npp",
        "src/simplex"
    )

    if is_kind("shared") then
        add_files("*.def")
    end

    if is_plat("windows", "mingw", "msys") then
        add_defines("__WOE__=1", "TLS=__declspec(thread)")
    end

    add_packages("zlib")

    add_headerfiles("src/glpk.h")

target("glpsol")
    set_kind("binary")
    add_files("examples/glpsol.c")
    add_deps("glpk")
