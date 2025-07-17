option("bitswidth", {default = "64", type = "string", values = {"64", "32"}})
set_version("1.0.0")

includes("@builtin/check")

configvar_check_cfuncs("BACKTRACE_SUPPORTED", "backtrace", {includes = "execinfo.h"})
configvar_check_cfuncs("BACKTRACE_SUPPORTS_THREADS", "backtrace_create_state", {includes = "execinfo.h"})
configvar_check_cfuncs("BACKTRACE_SUPPORTS_DATA", "backtrace_syminfo", {includes = "execinfo.h"})

configvar_check_cincludes("HAVE_DLFCN_H", "dlfcn.h")
configvar_check_cincludes("HAVE_INTTYPES_H", "inttypes.h")
configvar_check_cincludes("HAVE_LINK_H", "link.h")
configvar_check_cincludes("HAVE_MEMORY_H", "memory.h")
configvar_check_cincludes("HAVE_STDINT_H", "stdint.h")
configvar_check_cincludes("HAVE_STDLIB_H", "stdlib.h")
configvar_check_cincludes("HAVE_STRINGS_H", "strings.h")
configvar_check_cincludes("HAVE_STRING_H", "string.h")
configvar_check_cincludes("HAVE_SYS_LDR_H", "sys/ldr.h")
configvar_check_cincludes("HAVE_SYS_LINK_H", "sys/link.h")
configvar_check_cincludes("HAVE_SYS_STAT_H", "sys/stat.h")
configvar_check_cincludes("HAVE_SYS_TYPES_H", "sys/types.h")
configvar_check_cincludes("HAVE_TLHELP32_H", "tlhelp32.h")
configvar_check_cincludes("HAVE_UNISTD_H", "unistd.h")

configvar_check_cfuncs("HAVE_CLOCK_GETTIME", "clock_gettime", {includes = "time.h"})
configvar_check_cfuncs("HAVE_FCNTL", "fcntl", {includes = "fcntl.h"})
configvar_check_cfuncs("HAVE_LSTAT", "lstat", {includes = "sys/stat.h"})
configvar_check_cfuncs("HAVE_READLINK", "readlink", {includes = "unistd.h"})

configvar_check_cfuncs("HAVE_DECL_GETPAGESIZE", "getpagesize", {includes = "unistd.h"})
configvar_check_cfuncs("HAVE_DECL_STRNLEN", "strnlen", {includes = "string.h"})
configvar_check_cfuncs("HAVE_DECL__PGMPTR", "_pgmptr", {includes = {"stdlib.h", "stdio.h"}})
configvar_check_csnippets("HAVE_ATOMIC_FUNCTIONS", [[#include <stdio.h>
#include <stdatomic.h>
#include <stdint.h>
void test() { uint64_t *v;
__atomic_store_n(&v, 0, __ATOMIC_ACQUIRE); }]])

option("HAVE_GETIPINFO")
    add_cincludes("unwind.h")
    add_cfuncs("_Unwind_GetIPInfo")
    set_configvar("HAVE_GETIPINFO", 1)
    set_showmenu(false)
option_end()

if is_plat("wasm") then
    set_configvar("HAVE_DL_ITERATE_PHDR", 0)
else
    option("HAVE_DL_ITERATE_PHDR")
        add_cincludes("link.h")
        add_cfuncs("dl_iterate_phdr")
        add_defines("_GNU_SOURCE")
        set_configvar("HAVE_DL_ITERATE_PHDR", 1)
        set_showmenu(false)
    option_end()
end
option("HAVE_MACH_O_DYLD_H")
    add_cincludes("mach-o/dyld.h")
    set_configvar("HAVE_MACH_O_DYLD_H", 1)
    set_showmenu(false)
option_end()

option("HAVE_WINDOWS_H")
    add_cincludes("windows.h")
    set_configvar("HAVE_WINDOWS_H", 1)
    set_showmenu(false)
option_end()

option("HAVE_LOADQUERY")
    add_cincludes("sys/ldr.h")
    add_defines("_GNU_SOURCE")
    set_configvar("HAVE_LOADQUERY", 1)
    set_showmenu(false)
option_end()

option("HAVE_SYS_MMAN_H")
    add_cincludes("sys/mman.h")
    set_configvar("HAVE_SYS_MMAN_H", 1)
    set_showmenu(false)
option_end()

if has_config("HAVE_SYS_MMAN_H") then
    set_configvar("BACKTRACE_USES_MALLOC", 0)
else
    set_configvar("BACKTRACE_USES_MALLOC", 1)
end

configvar_check_cfuncs("HAVE_GETEXECNAME", "getexecname", {includes = "stdlib.h"})
configvar_check_cfuncs("HAVE_KERN_PROC", "KERN_PROC", {includes = "sys/sysctl.h"})
configvar_check_cfuncs("HAVE_KERN_PROC_ARGS", "KERN_PROC_ARGS", {includes = "sys/sysctl.h"})
configvar_check_csnippets("HAVE_SYNC_FUNCTIONS", [[#include <stdio.h>
#include <pthread.h>
void test() { __sync_synchronize(); }]])

if has_config("bitswidth") then
    if get_config("bitswidth") == "64" then
        set_configvar("BACKTRACE_ELF_SIZE", 64)
        set_configvar("BACKTRACE_XCOFF_SIZE", 64)
    else
        set_configvar("BACKTRACE_ELF_SIZE", 32)
        set_configvar("BACKTRACE_XCOFF_SIZE", 32)
    end
end

set_configvar("HAVE_LIBLZMA", 1)
set_configvar("HAVE_ZLIB", 1)
set_configvar("HAVE_ZSTD", 1)

add_requires("xz", "zlib", "zstd")

if is_plat("windows") then
    add_requires("unistd_h")
end

set_languages("c11")
add_rules("utils.install.cmake_importfiles")
add_rules("mode.debug", "mode.release")

target("libbacktrace")
    set_kind("$(kind)")
    add_options("HAVE_GETIPINFO", "HAVE_MACH_O_DYLD_H", "HAVE_WINDOWS_H", "HAVE_LOADQUERY", "HAVE_SYS_MMAN_H")
    if not is_plat("wasm") then
        add_options("HAVE_DL_ITERATE_PHDR")
    else
        add_defines("_POSIX_C_SOURCE=200809L", "_DEFAULT_SOURCE")
    end
    add_includedirs(".")
    add_headerfiles("backtrace.h")
    set_configdir(".")
    add_configfiles("(config.h.in)", {filename = "config.h"})
    add_configfiles("(backtrace-supported.h.in)", {filename = "backtrace-supported.h"})
    add_files("atomic.c", "dwarf.c", "fileline.c", "posix.c", "print.c", "sort.c", "state.c")
    add_packages("xz", "zlib", "zstd")
    if is_plat("windows") then
        add_packages("unistd_h")
    end

    if is_plat("linux", "bsd") then
        add_syslinks("dl", "m", "pthread", "rt")
    elseif is_plat("macosx", "iphoneos") then
        add_defines("_DARWIN_USE_64_BIT_INODE=1")
    end

    if has_config("HAVE_GETIPINFO") and has_config("HAVE_DL_ITERATE_PHDR") then
        add_files("backtrace.c")
    elseif has_config("HAVE_DL_ITERATE_PHDR") then
        add_files("simple.c")
    else
        add_files("nounwind.c")
    end
    
    if has_config("HAVE_DL_ITERATE_PHDR") then
        add_files("elf.c")
    elseif has_config("HAVE_MACH_O_DYLD_H") then
        add_files("macho.c")
    elseif has_config("HAVE_WINDOWS_H") then
        add_files("pecoff.c")
    elseif has_config("HAVE_LOADQUERY") then
        add_files("xcoff.c")
    else
        add_files("unknown.c")
    end

    if has_config("HAVE_SYS_MMAN_H") then
        add_files("mmapio.c", "mmap.c")
    else
        add_files("read.c", "alloc.c")
    end

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end
