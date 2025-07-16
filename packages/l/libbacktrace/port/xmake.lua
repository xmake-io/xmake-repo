option("arch64", {default = "64", type = "string", values = {"64", "32"}})

includes("@builtin/check")

configvar_check_cfuncs("BACKTRACE_SUPPORTED", "backtrace", {includes = "execinfo.h"})
if is_plat("linux", "android", "bsd") then
    set_configvar("BACKTRACE_USES_MALLOC", 0)
else
    set_configvar("BACKTRACE_USES_MALLOC", 1)
end
configvar_check_cfuncs("BACKTRACE_SUPPORTS_THREADS", "backtrace_create_state", {includes = "execinfo.h"})
configvar_check_cfuncs("BACKTRACE_SUPPORTS_DATA", "backtrace_syminfo", {includes = "execinfo.h"})

configvar_check_cincludes("HAVE_DLFCN_H", "dlfcn.h")
configvar_check_cincludes("HAVE_INTTYPES_H", "inttypes.h")
configvar_check_cincludes("HAVE_LINK_H", "link.h")
configvar_check_cincludes("HAVE_MACH_O_DYLD_H", "mach-o/dyld.h")
configvar_check_cincludes("HAVE_MEMORY_H", "memory.h")
configvar_check_cincludes("HAVE_STDINT_H", "stdint.h")
configvar_check_cincludes("HAVE_STDLIB_H", "stdlib.h")
configvar_check_cincludes("HAVE_STRINGS_H", "strings.h")
configvar_check_cincludes("HAVE_STRING_H", "string.h")
configvar_check_cincludes("HAVE_SYS_LDR_H", "sys/ldr.h")
configvar_check_cincludes("HAVE_SYS_LINK_H", "sys/link.h")
configvar_check_cincludes("HAVE_SYS_MMAN_H", "sys/mman.h")
configvar_check_cincludes("HAVE_SYS_STAT_H", "sys/stat.h")
configvar_check_cincludes("HAVE_SYS_TYPES_H", "sys/types.h")
configvar_check_cincludes("HAVE_TLHELP32_H", "tlhelp32.h")
configvar_check_cincludes("HAVE_UNISTD_H", "unistd.h")
configvar_check_cincludes("HAVE_WINDOWS_H", "windows.h")

configvar_check_cfuncs("HAVE_CLOCK_GETTIME", "clock_gettime", {includes = "time.h"})
configvar_check_cfuncs("HAVE_FCNTL", "fcntl", {includes = "fcntl.h"})
configvar_check_cfuncs("HAVE_LSTAT", "lstat", {includes = "sys/stat.h"})
configvar_check_cfuncs("HAVE_READLINK", "readlink", {includes = "unistd.h"})

configvar_check_cfuncs("HAVE_DECL_GETPAGESIZE", "getpagesize", {includes = "unistd.h"})
configvar_check_cfuncs("HAVE_DECL_STRNLEN", "strnlen", {includes = "string.h"})
configvar_check_cfuncs("HAVE_DECL__PGMPTR", "_pgmptr", {includes = {"stdlib.h", "stdio.h"}})
configvar_check_cfuncs("HAVE_ATOMIC_FUNCTIONS", "__atomic_store_n", {includes = {"stdio.h", "stdatomic.h"}})

configvar_check_cfuncs("HAVE_DL_ITERATE_PHDR", "dl_iterate_phdr", {includes = "link.h"})
configvar_check_cfuncs("HAVE_GETEXECNAME", "getexecname", {includes = "stdlib.h"})
configvar_check_cfuncs("HAVE_GETIPINFO", "_Unwind_GetIPInfo", {includes = "unwind.h"})

configvar_check_cfuncs("HAVE_KERN_PROC", "KERN_PROC", {includes = "sys/sysctl.h"})
configvar_check_cfuncs("HAVE_KERN_PROC_ARGS", "KERN_PROC_ARGS", {includes = "sys/sysctl.h"})
configvar_check_cfuncs("HAVE_LOADQUERY", "loadquery", {includes = "sys/ldr.h"})

configvar_check_cfuncs("HAVE_SYNC_FUNCTIONS", "__sync_synchronize", {includes = {"stdio.h", "pthread.h"}})

if has_config("arch64") then
    if get_config("arch64") == "64" then
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

set_languages("c++11")
add_rules("utils.install.cmake_importfiles")
add_rules("mode.debug", "mode.release")

target("libbacktrace")
    set_kind("$(kind)")
    add_includedirs(".")
    add_headerfiles("backtrace.h")
    set_configdir(".")
    add_configfiles("(config.h.in)", {filename = "config.h"})
    add_configfiles("(backtrace-supported.h.in)", {filename = "backtrace-supported.h"})
    add_files("atomic.c", "dwarf.c", "fileline.c", "posix.c", "print.c", "sort.c", "state.c")
    add_packages("xz", "zlib", "zstd")

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
        set_configvar("HAVE_ELF", 1)
    elseif has_config("HAVE_MACH_O_DYLD_H") then
        add_files("macho.c")
        set_configvar("HAVE_MACH_O", 1)
    elseif has_config("HAVE_WINDOWS_H") then
        add_files("pecoff.c")
        set_configvar("HAVE_PECOFF", 1)
    elseif has_config("HAVE_LOADQUERY") then
        add_files("xcoff.c")
        set_configvar("HAVE_XCOFF", 1)
    else
        add_files("unknown.c")
    end
    
    if has_config("HAVE_SYS_MMAN_H") then
        add_files("mmapio.c", "mmap.c")
    else
        add_files("read.c", "alloc.c")
    end
