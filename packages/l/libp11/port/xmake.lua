add_rules("mode.debug", "mode.release")
set_languages("c11")
add_requires("openssl")
includes("@builtin/check")
configvar_check_cfuncs("HAVE_X509_GET0_NOTBEFORE", "X509_get0_notBefore", {includes = "openssl/x509.h"})
configvar_check_cfuncs("HAVE_X509_GET0_NOTAFTER", "X509_get0_notAfter", {includes = "openssl/x509.h"})

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
    add_files("src/*.c")
    add_headerfiles("src/libp11.h", "src/p11_err.h", "src/util.h")
    add_includedirs("src")
    add_packages("openssl")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end

    if is_plat("windows", "mingw") then
        add_configfiles("src/libp11.rc.in")
        add_configfiles("src/pkcs11.rc.in")
    end

    if is_plat("windows", "mingw", "cygwin") then
        add_defines("WIN32_LEAN_AND_MEAN", "_WIN32_WINNT=0x0600")
        add_syslinks("ws2_32", "user32", "advapi32", "crypt32", "gdi32")
        if is_plat("cygwin") then
            add_defines("USE_CYGWIN")
        end
    elseif is_plat("linux", "bsd", "android") then
        add_syslinks("pthread", "dl")
        add_configfiles("src/(config.h.in)", {filename = "config.h"})
    end
