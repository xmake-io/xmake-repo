add_rules("mode.debug", "mode.release")
set_languages("c11")
add_requires("openssl")

includes("@builtin/check")

configvar_check_cincludes("HAVE_DLFCN_H", "dlfcn.h", {default = 0})
configvar_check_cincludes("HAVE_ERRNO_H", "errno.h", {default = 0})
configvar_check_cincludes("HAVE_FCNTL_H", "fcntl.h", {default = 0})
configvar_check_cincludes("HAVE_GETOPT_H", "getopt.h", {default = 0})
configvar_check_cincludes("HAVE_INTTYPES_H", "inttypes.h", {default = 0})
configvar_check_cincludes("HAVE_LOCALE_H", "locale.h", {default = 0})
configvar_check_cincludes("HAVE_MALLOC_H", "malloc.h", {default = 0})

configvar_check_cincludes("HAVE_STDINT_H", "stdint.h", {default = 0})
configvar_check_cincludes("HAVE_STDIO_H", "stdio.h", {default = 0})
configvar_check_cincludes("HAVE_STDLIB_H", "stdlib.h", {default = 0})
configvar_check_cincludes("HAVE_STRINGS_H", "strings.h", {default = 0})
configvar_check_cincludes("HAVE_STRING_H", "string.h", {default = 0})
configvar_check_cincludes("HAVE_SYS_STAT_H", "sys/stat.h", {default = 0})
configvar_check_cincludes("HAVE_SYS_TIME_H", "sys/time.h", {default = 0})
configvar_check_cincludes("HAVE_SYS_TYPES_H", "sys/types.h", {default = 0})
configvar_check_cincludes("HAVE_SYS_WAIT_H", "sys/wait.h", {default = 0})
configvar_check_cincludes("HAVE_UNISTD_H", "unistd.h", {default = 0})
configvar_check_cincludes("HAVE_UTMP_H", "utmp.h", {default = 0})

configvar_check_cfuncs("HAVE_X509_GET0_NOTBEFORE", "X509_get0_notBefore", {includes = "openssl/x509.h", default = 0})
configvar_check_cfuncs("HAVE_X509_GET0_NOTAFTER", "X509_get0_notAfter", {includes = "openssl/x509.h", default = 0})

if is_plat("android") then
    configvar_check_cfuncs("HAVE_PTHREAD", "pthread_create", {includes = "pthread.h"})
else
    configvar_check_links("HAVE_PTHREAD", "pthread")
end

configvar_check_csnippets("HAVE_PTHREAD_PRIO_INHERIT", [[
#include <pthread.h>
void test() {
    int i = PTHREAD_PRIO_INHERIT;
    return i; 
}]])

target("libp11")
    set_kind("$(kind)")

    add_packages("openssl")

    set_configdir("src")
    add_configfiles("src/(config.h.in)", {filename = "config.h"})

    add_includedirs("src")
    add_files("src/*.c")
    add_headerfiles("src/libp11.h", "src/p11_err.h", "src/util.h")

    if is_plat("windows", "mingw", "cygwin") then
        add_defines("WIN32_LEAN_AND_MEAN", "_WIN32_WINNT=0x0600")
        add_syslinks("ws2_32", "user32", "advapi32", "crypt32", "gdi32")
        if is_plat("cygwin") then
            add_defines("USE_CYGWIN")
        end
    elseif is_plat("linux", "bsd", "android") then
        add_defines("HAVE_PTHREAD", "_DEFAULT_SOURCE", "_POSIX_C_SOURCE=200809L")
        add_syslinks("pthread", "dl")
    end

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end

    if is_plat("windows", "mingw") then
        add_configfiles("src/libp11.rc.in")
        add_configfiles("src/pkcs11.rc.in")
    end
