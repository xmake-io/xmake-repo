option("ver", {default = nil})

add_rules("mode.debug", "mode.release")
if has_config("ver") then
    set_version(get_config("ver"), {soname = true})
end

includes("@builtin/check")

target("fcgi")
    set_kind("$(kind)")
    add_files("libfcgi/*.c|os_*.c")
    if is_plat("windows", "mingw") then
        add_files("libfcgi/os_win32.c")
    else
        add_files("libfcgi/os_unix.c")
    end
    if is_plat("windows") then
        if is_kind("static") then
            add_defines("DLLAPI=", {public = true})
        else
            add_defines("DLLAPI=__declspec(dllexport)")
        end
    end
    add_includedirs("include", {public = true})
    add_headerfiles("include/*.h|fcgi_config_x86.h")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    set_configdir("include")
    add_configfiles("fcgi_config.h.in")
        
    local header_map = {
        HAVE_ARPA_INET_H = "arpa/inet.h",
        HAVE_DLFCN_H = "dlfcn.h",
        HAVE_INTTYPES_H = "inttypes.h",
        HAVE_LIMITS_H = "limits.h",
        HAVE_MEMORY_H = "memory.h",
        HAVE_NETDB_H = "netdb.h",
        HAVE_NETINET_IN_H = "netinet/in.h",
        HAVE_STDINT_H = "stdint.h",
        HAVE_STDLIB_H = "stdlib.h",
        HAVE_STRINGS_H = "strings.h",
        HAVE_STRING_H = "string.h",
        HAVE_SYS_PARAM_H = "sys/param.h",
        HAVE_SYS_SOCKET_H = "sys/socket.h",
        HAVE_SYS_STAT_H = "sys/stat.h",
        HAVE_SYS_TIME_H = "sys/time.h",
        HAVE_SYS_TYPES_H = "sys/types.h",
        HAVE_UNISTD_H = "unistd.h"
    }
    for macro, header in pairs(header_map) do
        configvar_check_cincludes(macro, header)
    end
    configvar_check_cfuncs("HAVE_STRERROR", "strerror", {includes = {"string.h"}})
    configvar_check_cfuncs("HAVE_FILENO_PROTO", "fileno", {includes = {"stdio.h"}})
    configvar_check_ctypes("HAVE_FPOS", "fpos_t", {includes = "stdio.h"})
    configvar_check_ctypes("HAVE_SOCKLEN", "socklen_t", {includes = "sys/socket.h"})
    configvar_check_csnippets("HAVE_SOCKADDR_UN_SUN_LEN", [[
        struct sockaddr_un addr;
        addr.sun_len = 0;
    ]], {includes = "sys/un.h"})
    configvar_check_csnippets("HAVE_VA_ARG_LONG_DOUBLE_BUG", [[
        long double lDblArg; va_list arg; lDblArg = va_arg(arg, long double);
    ]], {includes = "stdarg.h"})

target("fcgi++")
    set_kind("$(kind)")
    add_files("libfcgi/*.cpp")
    if is_plat("windows") then
        if is_kind("static") then
            add_defines("DLLAPI=", {public = true})
        else
            add_defines("DLLAPI=__declspec(dllexport)")
        end
    end
    add_deps("fcgi")

target("cgi-fcgi")
    set_kind("binary")
    add_files("cgi-fcgi/cgi-fcgi.c")
    add_deps("fcgi")
