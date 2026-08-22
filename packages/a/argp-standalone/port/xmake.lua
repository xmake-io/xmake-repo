add_rules("mode.debug", "mode.release")

includes("@builtin/check")

configvar_check_cincludes("HAVE_UNISTD_H", "unistd.h")
configvar_check_cincludes("HAVE_ALLOCA_H", "alloca.h")
configvar_check_cincludes("HAVE_MALLOC_H", "malloc.h")
configvar_check_cincludes("HAVE_LIBINTL_H", "libintl.h")
configvar_check_cfuncs("HAVE_ASPRINTF", "asprintf", {includes = "stdio.h", defines = "_GNU_SOURCE"})
configvar_check_cfuncs("HAVE_STRCHRNUL", "strchrnul", {includes = "string.h", defines = "_GNU_SOURCE"})
configvar_check_cfuncs("HAVE_STRNDUP", "strndup", {includes = "string.h"})
configvar_check_cfuncs("HAVE_MEMPCPY", "mempcpy", {includes = "string.h", defines = "_GNU_SOURCE"})
configvar_check_cfuncs("HAVE_DECL_PROGRAM_INVOCATION_NAME", "program_invocation_name", {includes = "errno.h", defines = "_GNU_SOURCE"})
configvar_check_cfuncs("HAVE_DECL_PROGRAM_INVOCATION_SHORT_NAME", "program_invocation_short_name", {includes = "errno.h", defines = "_GNU_SOURCE"})
configvar_check_cfuncs("HAVE_DECL_FWRITE_UNLOCKED", "fwrite_unlocked", {includes = "stdio.h"})
configvar_check_cfuncs("HAVE_DECL_FPUTS_UNLOCKED", "fputs_unlocked", {includes = "stdio.h"})
configvar_check_cfuncs("HAVE_DECL_FPUTC_UNLOCKED", "fputc_unlocked", {includes = "stdio.h"})
configvar_check_cfuncs("HAVE_DECL_PUTC_UNLOCKED", "putc_unlocked", {includes = "stdio.h"})
configvar_check_cfuncs("HAVE_DECL_CLEARERR_UNLOCKED", "clearerr_unlocked", {includes = "stdio.h"})
configvar_check_cfuncs("HAVE_DECL_FEOF_UNLOCKED", "feof_unlocked", {includes = "stdio.h"})
configvar_check_cfuncs("HAVE_DECL_FERROR_UNLOCKED", "ferror_unlocked", {includes = "stdio.h"})
configvar_check_cfuncs("HAVE_DECL_FFLUSH_UNLOCKED", "fflush_unlocked", {includes = "stdio.h"})
configvar_check_cfuncs("HAVE_DECL_FGETS_UNLOCKED", "fgets_unlocked", {includes = "stdio.h"})
configvar_check_cfuncs("HAVE_DECL_FLOCKFILE", "flockfile", {includes = "stdio.h"})

target("argp")
    set_kind("$(kind)")
    add_files("argp-ba.c", "argp-eexst.c", "argp-fmtstream.c",
              "argp-help.c", "argp-parse.c", "argp-pv.c", "argp-pvh.c")
    add_headerfiles("argp.h")

    add_defines("HAVE_CONFIG_H")
    set_configdir("$(builddir)")
    add_configfiles("config.h.in")
    add_includedirs("$(builddir)")
    add_includedirs(".")

    on_config(function (target)
        if not target:has_cfuncs("mempcpy", {includes = "string.h", defines = "_GNU_SOURCE"}) then
            target:add("files", path.join(os.projectdir(), "mempcpy.c"))
        end
        if not target:has_cfuncs("strchrnul", {includes = "string.h", defines = "_GNU_SOURCE"}) then
            target:add("files", path.join(os.projectdir(), "strchrnul.c"))
        end
        if not target:has_cfuncs("strndup", {includes = "string.h"}) then
            target:add("files", path.join(os.projectdir(), "strndup.c"))
        end
        if not target:has_cfuncs("strcasecmp", {includes = "strings.h"}) then
            target:add("files", path.join(os.projectdir(), "strcasecmp.c"))
        end
    end)
