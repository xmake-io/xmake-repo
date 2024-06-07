set_project("libintl")

add_rules("mode.debug", "mode.release")

set_configvar("PACKAGE", "gettext-runtime")
set_configvar("PACKAGE_NAME", "gettext-runtime")
set_configvar("PACKAGE_TARNAME", "gettext-runtime")
set_configvar("PACKAGE_BUGREPORT", "bug-gettext@gnu.org")
set_configvar("PACKAGE_URL", "")

option("installprefix")
    set_default("")
    set_showmenu(true)
option_end()
set_configvar("INSTALLPREFIX", get_config("installprefix"))
if has_config("installprefix") then
    add_defines("LOCALEDIR=\"" .. get_config("installprefix") .. "/locale\"")
    add_defines("LOCALE_ALIAS_PATH=\"" .. get_config("installprefix") .. "/locale\"")
end

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

includes("check_cfuncs.lua")
includes("check_ctypes.lua")
includes("check_macros.lua")
includes("check_links.lua")
includes("check_cincludes.lua")
includes("check_csnippets.lua")

-- general autoconf variables
option("GNULIB_STRERROR")
    add_csnippets("strerror", [[#include <string.h>
int test() { if (!*strerror(-2)) { return 1; } return 0; }]])
    set_configvar("GNULIB_STRERROR", 1)
option_end()
add_options("GNULIB_STRERROR")
option("HAVE_UID_T")
    add_ctypes("uid_t")
    add_cincludes("stdlib.h")
option_end()
if not has_config("HAVE_UID_T") then
    set_configvar("uid_t", "int", {quote = false})
end
option("HAVE_SSIZE_T")
    add_ctypes("ssize_t")
    add_cincludes("sys/types.h")
option_end()
if not has_config("HAVE_SSIZE_T") then
    set_configvar("ssize_t", "int", {quote = false})
end
option("HAVE_NLINK_T")
    add_ctypes("nlink_t")
    add_cincludes("sys/types.h")
option_end()
if not has_config("HAVE_NLINK_T") then
    set_configvar("nlink_t", "int", {quote = false})
end
set_configvar("LT_OBJDIR", ".libs/")
set_configvar("HAVE_INLINE", 1)
set_configvar("_ALL_SOURCE", 1)
set_configvar("_DARWIN_C_SOURCE", 1)
set_configvar("_GNU_SOURCE", 1)
set_configvar("_NETBSD_SOURCE", 1)
set_configvar("_OPENBSD_SOURCE", 1)
set_configvar("_POSIX_PTHREAD_SEMANTICS", 1)
set_configvar("__STDC_WANT_IEC_60559_ATTRIBS_EXT__", 1)
set_configvar("__STDC_WANT_IEC_60559_BFP_EXT__", 1)
set_configvar("__STDC_WANT_IEC_60559_DFP_EXT__", 1)
set_configvar("__STDC_WANT_IEC_60559_FUNCS_EXT__", 1)
set_configvar("__STDC_WANT_IEC_60559_TYPES_EXT__", 1)
set_configvar("__STDC_WANT_LIB_EXT2__", 1)
set_configvar("__STDC_WANT_MATH_SPEC_FUNCS__", 1)
set_configvar("_TANDEM_SOURCE", 1)
set_configvar("__EXTENSIONS__", 1)
set_configvar("ENABLE_EXTRA", 1)
set_configvar("_USE_STD_STAT", 1)
set_configvar("__USE_MINGW_ANSI_STDIO", 1)
set_configvar("STDC_HEADERS", 1)
set_configvar("USE_UNLOCKED_IO", 1)
set_configvar("GNULIB_MSVC_NOTHROW", 1)
set_configvar("GNULIB_CANONICALIZE_LGPL", 1)
set_configvar("GNULIB_TEST_CANONICALIZE_FILE_NAME", 1)
set_configvar("GNULIB_TEST_ENVIRON", 1)
set_configvar("GNULIB_TEST_LSTAT", 1)
set_configvar("GNULIB_TEST_MALLOC_POSIX", 1)
set_configvar("GNULIB_TEST_RAISE", 1)
set_configvar("GNULIB_TEST_READ", 1)
set_configvar("GNULIB_TEST_READLINK", 1)
set_configvar("GNULIB_TEST_REALPATH", 1)
set_configvar("GNULIB_TEST_SIGPROCMASK", 1)
set_configvar("GNULIB_TEST_STAT", 1)
set_configvar("GNULIB_TEST_STRERROR", 1)
set_configvar("GNULIB_TEST_STRNLEN", 1)
set_configvar("GNULIB_TEST_WCWIDTH", 1)
set_configvar("GNULIB_UNISTR_U8_MBTOUCR", 1)
set_configvar("GNULIB_UNISTR_U8_UCTOMB", 1)
configvar_check_cincludes("ENABLE_NLS", "libintl.h", {default = 0})
configvar_check_cincludes("HAVE_DLFCN_H", "dlfcn.h")
configvar_check_cincludes("HAVE_INTTYPES_H", "inttypes.h")
configvar_check_cincludes("HAVE_MACH_O_DYLD_H", "mach-o/dyld.h")
configvar_check_cincludes("HAVE_MEMORY_H", "memory.h")
configvar_check_cincludes("HAVE_STDINT_H", "stdint.h")
configvar_check_cincludes("HAVE_STDDEF_H", "stddef.h")
configvar_check_cincludes("HAVE_STDLIB_H", "stdlib.h")
configvar_check_cincludes("HAVE_STRINGS_H", "strings.h")
configvar_check_cincludes("HAVE_STRING_H", "string.h")
configvar_check_cincludes("HAVE_SYS_STAT_H", "sys/stat.h")
configvar_check_cincludes("HAVE_SYS_TYPES_H", "sys/types.h")
configvar_check_cincludes("HAVE_SYS_MMAN_H", "sys/mman.h")
configvar_check_cincludes("HAVE_UNISTD_H", "unistd.h")
configvar_check_cincludes("HAVE_ALLOCA_H", "alloca.h")
configvar_check_cincludes("HAVE_SEARCH_H", "search.h")
configvar_check_cincludes("HAVE_SYS_BITYPES_H", "sys/bitypes.h")
configvar_check_cincludes("HAVE_WCHAR_H", "wchar.h")
configvar_check_cincludes("HAVE_WCTYPE_H", "wctype.h")
configvar_check_cincludes("HAVE_WINSOCK2_H", "winsock2.h")
configvar_check_cincludes("HAVE_CRTDEFS_H", "crtdefs.h")
configvar_check_cincludes("HAVE_BP_SYM_H", "bp-sym.h")
configvar_check_cincludes("HAVE_XLOCALE_H", "xlocale.h")
configvar_check_cfuncs("HAVE__NSGETEXECUTABLEPATH", "_NSGetExecutablePath")
configvar_check_cfuncs("HAVE_MSVC_INVALID_PARAMETER_HANDLER", "_set_invalid_parameter_handler")
configvar_check_cfuncs("HAVE_SETLOCALE", "setlocale", {includes = "locale.h"})
configvar_check_cfuncs("HAVE_SYMLINK", "symlink", {includes = "unistd.h"})
configvar_check_cfuncs("GNULIB_FSCANF", "fscanf", {includes = "stdio.h"})
configvar_check_cfuncs("GNULIB_SCANF", "scanf", {includes = "stdio.h"})
configvar_check_cfuncs("HAVE_CANONICALIZE_FILE_NAME", "canonicalize_file_name", {includes = "stdlib.h", defines = "_GNU_SOURCE"})
configvar_check_cfuncs("HAVE_DECL_CLEARERR_UNLOCKED", "clearerr_unlocked", {includes = "stdio.h", default = 0})
configvar_check_cfuncs("HAVE_DECL_FEOF_UNLOCKED", "feof_unlocked", {includes = "stdio.h", default = 0})
configvar_check_cfuncs("HAVE_DECL_FERROR_UNLOCKED", "ferror_unlocked", {includes = "stdio.h", default = 0})
configvar_check_cfuncs("HAVE_DECL_FFLUSH_UNLOCKED", "fflush_unlocked", {includes = "stdio.h", default = 0})
configvar_check_cfuncs("HAVE_DECL_FGETS_UNLOCKED", "fgets_unlocked", {includes = "stdio.h", defines = "_GNU_SOURCE", default = 0})
configvar_check_cfuncs("HAVE_DECL_FPUTC_UNLOCKED", "fputc_unlocked", {includes = "stdio.h", default = 0})
configvar_check_cfuncs("HAVE_DECL_FREAD_UNLOCKED", "fread_unlocked", {includes = "stdio.h", default = 0})
configvar_check_cfuncs("HAVE_DECL_FWRITE_UNLOCKED", "fwrite_unlocked", {includes = "stdio.h", default = 0})
configvar_check_cfuncs("HAVE_DECL_GETCHAR_UNLOCKED", "getchar_unlocked", {includes = "stdio.h", default = 0})
configvar_check_cfuncs("HAVE_DECL_GETC_UNLOCKED", "getc_unlocked", {includes = "stdio.h", default = 0})
configvar_check_cfuncs("HAVE_DECL_PUTCHAR_UNLOCKED", "putchar_unlocked", {includes = "stdio.h", default = 0})
configvar_check_cfuncs("HAVE_DECL_PUTC_UNLOCKED", "putc_unlocked", {includes = "stdio.h", default = 0})
configvar_check_cfuncs("HAVE_DECL_SETENV", "setenv", {includes = "stdlib.h", default = 0})
configvar_check_cfuncs("HAVE_DECL_STRERROR_R", "strerror_r", {includes = "string.h", default = 0})
configvar_check_cfuncs("HAVE_SETENV", "setenv", {includes = "stdlib.h"})
configvar_check_cfuncs("HAVE_PUTENV", "putenv", {includes = "stdlib.h"})
configvar_check_cfuncs("HAVE_GETCWD", "getcwd", {includes = "unistd.h"})
configvar_check_cfuncs("HAVE_GETEXECNAME", "getexecname", {includes = "stdlib.h"})
configvar_check_cfuncs("HAVE_GETPROGNAME", "getprogname", {includes = "stdlib.h"})
configvar_check_cfuncs("HAVE_LSTAT", "lstat", {includes = "sys/stat.h"})
configvar_check_cfuncs("HAVE_MALLOC_POSIX", "malloc", {includes = "stdlib.h"})
configvar_check_cfuncs("HAVE_ATEXIT", "atexit", {includes = "stdlib.h"})
configvar_check_cfuncs("HAVE_MBRTOWC", "mbrtowc", {includes = "wchar.h"})
configvar_check_cfuncs("HAVE_WCRTOMB", "wcrtomb", {includes = "wchar.h"})
configvar_check_cfuncs("HAVE_WCSLEN", "wcslen", {includes = "wchar.h"})
configvar_check_cfuncs("HAVE_WCWIDTH", "wcwidth", {includes = "wchar.h"})
configvar_check_cfuncs("HAVE_WCSNLEN", "wcsnlen", {includes = "wchar.h"})
configvar_check_cfuncs("HAVE_MBSINIT", "mbsinit", {includes = "wchar.h"})
configvar_check_cfuncs("HAVE_BTOWC", "btowc", {includes = "wchar.h"})
configvar_check_cfuncs("HAVE_ISWBLANK", "iswblank", {includes = "wctype.h"})
configvar_check_cfuncs("HAVE_ISWCNTRL", "iswcntrl", {includes = "wctype.h"})
configvar_check_cfuncs("HAVE_RAISE", "raise", {includes = "signal.h"})
configvar_check_cfuncs("HAVE_READLINK", "readlink", {includes = "unistd.h"})
configvar_check_cfuncs("HAVE_READLINKAT", "readlinkat", {includes = "unistd.h"})
configvar_check_cfuncs("HAVE_REALPATH", "realpath", {includes = "stdlib.h"})
configvar_check_cfuncs("FUNC_REALPATH_WORKS", "realpath", {includes = "stdlib.h"})
configvar_check_cfuncs("HAVE_TSEARCH", "tsearch", {includes = "search.h"})
configvar_check_cfuncs("HAVE_STPCPY", "stpcpy", {includes = "string.h"})
configvar_check_cfuncs("HAVE_STRDUP", "strdup", {includes = "string.h"})
configvar_check_cfuncs("HAVE_STRTOUL", "strtoul", {includes = "string.h"})
configvar_check_cfuncs("HAVE_MEMPCPY", "mempcpy", {includes = "string.h", defines = "_GNU_SOURCE"})
configvar_check_cfuncs("HAVE_MMAP", "mmap", {includes = "sys/mman.h"})
configvar_check_cfuncs("HAVE_MPROTECT", "mprotect", {includes = "sys/mman.h"})
configvar_check_cfuncs("HAVE_MUNMAP", "munmap", {includes = "sys/mman.h"})
configvar_check_ctypes("HAVE_LONG_LONG_INT", "long long int")
configvar_check_ctypes("HAVE_UNSIGNED_LONG_LONG_INT", "unsigned long long int")
configvar_check_ctypes("HAVE__BOOL", "_Bool")
configvar_check_ctypes("HAVE_WCHAR_T", "wchar_t", {includes = "wchar.h"})
configvar_check_ctypes("HAVE_WINT_T", "wint_t", {includes = "wchar.h"})
configvar_check_ctypes("HAVE_SIGSET_T", "sigset_t", {includes = "signal.h"})
configvar_check_macros("HAVE_MSVC_INVALID_PARAMETER_HANDLER", "_MSC_VER")
configvar_check_csnippets("HAVE_VISIBILITY", [[
extern __attribute__((__visibility__("hidden"))) int hiddenvar;
extern __attribute__((__visibility__("default"))) int exportedvar;
extern __attribute__((__visibility__("hidden"))) int hiddenfunc(void);
extern __attribute__((__visibility__("default"))) int exportedfunc(void);]], {default = 0})
configvar_check_csnippets("HAVE_STRUCT_STAT_ST_ATIM_TV_NSEC", [[#include <sys/types.h>
#include <sys/stat.h>
struct stat st;
void test() { st.st_atim.tv_nsec; }]])
configvar_check_csnippets("TYPEOF_STRUCT_STAT_ST_ATIM_IS_STRUCT_TIMESPEC", [[#include <sys/types.h>
#include <sys/stat.h>
#if HAVE_SYS_TIME_H
# include <sys/time.h>
#endif
#include <time.h>
struct timespec ts;
struct stat st;
void test() { st.st_atim = ts; }]])
configvar_check_csnippets("PROGRAM_INVOCATION_NAME", [[#define _GNU_SOURCE
#include <errno.h>
extern char *program_invocation_name;]])
configvar_check_csnippets("PROGRAM_INVOCATION_SHORT_NAME", [[#define _GNU_SOURCE
#include <errno.h>
extern char *program_invocation_short_name;]])
configvar_check_csnippets("GNULIB_SIGPIPE", [[#include <signal.h>
#ifndef SIGPIPE
#error SIGPIPE not defined
#endif]])
configvar_check_csnippets("HAVE_LANGINFO_CODESET", [[#include <langinfo.h>
int test() { char* cs = nl_langinfo(CODESET); return !cs; }]])
configvar_check_csnippets("HAVE_ENVIRON_DECL=0", [[extern struct {int foo;} environ;
void test() {environ.foo = 1;}]], {includes = is_plat("windows") and "stdlib.h" or "unistd.h", default = 1})

-- config.h variables
configvar_check_ctypes("HAVE_STDINT_H_WITH_UINTMAX", "uintmax_t", {includes = "stdint.h"})
configvar_check_ctypes("HAVE_UINTMAX_T", "uintmax_t", {includes = "stdint.h"})
if is_plat("android") then
    configvar_check_cfuncs("HAVE_PTHREAD_API", "pthread_create", {includes = "pthread.h"})
else
    configvar_check_links("HAVE_PTHREAD_API", "pthread")
end
configvar_check_csnippets("HAVE_ALLOCA", [[
#ifdef __GNUC__
# define alloca __builtin_alloca
#elif defined _MSC_VER
# include <malloc.h>
# define alloca _alloca
#else
# include <alloca.h>
#endif
void test() { char *p = (char *)alloca(1); }
]])
if is_plat("windows") and is_kind("shared") then
    set_configvar("WOE32DLL", 1)
end
set_configvar("SETLOCALE_NULL_ALL_MTSAFE", is_plat("windows", "linux") and 1 or 0)
set_configvar("SETLOCALE_NULL_ONE_MTSAFE", 1)
set_configvar("NEED_SETLOCALE_IMPROVED", is_plat("mingw") and 1 or 0)
set_configvar("NEED_SETLOCALE_MTSAFE", is_plat("windows", "linux") and 0 or 1)

-- libgnuintl.h variables
set_configvar("HAVE_NAMELESS_LOCALES", 0)
configvar_check_cfuncs("HAVE_NEWLOCALE", "newlocale", {includes = (is_plat("macosx") and "xlocale.h" or "locale.h"), default = 0})
configvar_check_cfuncs("HAVE_POSIX_PRINTF", "printf", {includes = "stdio.h", default = 0})
configvar_check_cfuncs("HAVE_WPRINTF", "wprintf", {includes = "wchar.h", default = 0})
configvar_check_cfuncs("HAVE_SNPRINTF", "snprintf", {includes = "stdio.h", default = 0})
configvar_check_cfuncs("HAVE_ASPRINTF", "asprintf", {includes = "stdio.h", default = 0})

target("intl")
    set_kind("$(kind)")
    add_defines("HAVE_CONFIG_H", "NO_XMALLOC", "IN_LIBRARY", "IN_LIBINTL")
    if is_kind("shared") then
        add_defines("BUILDING_LIBINTL", "BUILDING_DLL")
    end
    if is_plat("windows") then
        add_syslinks("advapi32")
    end
    set_configvar("HAVE_ICONV", 0)
    set_configvar("HAVE_ICONV_H", 0)
    add_defines("DEPENDS_ON_LIBICONV=0")
    set_configdir("gettext-runtime")
    add_configfiles("gettext-runtime/(intl/libgnuintl.in.h)", {filename = "libgnuintl.h", pattern = "@(.-)@"})
    add_configfiles("gettext-runtime/intl/(export.h)", {filename = "export.h", pattern = "@(.-)@"})
    add_configfiles("gettext-runtime/(config.h.in)", {filename = "config.h"})
    add_includedirs("gettext-runtime", "gettext-runtime/intl")
    add_files("gettext-runtime/intl/bindtextdom.c",
              "gettext-runtime/intl/dcigettext.c",
              "gettext-runtime/intl/dcngettext.c",
              "gettext-runtime/intl/dcgettext.c",
              "gettext-runtime/intl/dgettext.c",
              "gettext-runtime/intl/dngettext.c",
              "gettext-runtime/intl/explodename.c",
              "gettext-runtime/intl/finddomain.c",
              "gettext-runtime/intl/gettext.c",
              "gettext-runtime/intl/hash-string.c",
              "gettext-runtime/intl/intl-compat.c",
              "gettext-runtime/intl/l10nflist.c",
              "gettext-runtime/intl/langprefs.c",
              "gettext-runtime/intl/loadmsgcat.c",
              "gettext-runtime/intl/localealias.c",
              "gettext-runtime/intl/localename.c",
              "gettext-runtime/intl/localename-table.c",
              "gettext-runtime/intl/localcharset.c",
              "gettext-runtime/intl/lock.c",
              "gettext-runtime/intl/log.c",
              "gettext-runtime/intl/ngettext.c",
              "gettext-runtime/intl/osdep.c",
              "gettext-runtime/intl/plural.c",
              "gettext-runtime/intl/plural-exp.c",
              "gettext-runtime/intl/printf.c",
              "gettext-runtime/intl/relocatable.c",
              "gettext-runtime/intl/setlocale.c",
              "gettext-runtime/intl/setlocale-lock.c",
              "gettext-runtime/intl/setlocale_null.c",
              "gettext-runtime/intl/threadlib.c",
              "gettext-runtime/intl/textdomain.c",
              "gettext-runtime/intl/version.c",
              "gettext-runtime/intl/xsize.c")
    if is_plat("windows") then
        add_files("gettext-runtime/intl/windows-mutex.c",
                  "gettext-runtime/intl/windows-rwlock.c",
                  "gettext-runtime/intl/windows-recmutex.c",
                  "gettext-runtime/intl/windows-once.c")
    end
    before_build(function (target)
        os.cp("gettext-runtime/intl/libgnuintl.h", "gettext-runtime/intl/libintl.h")
        local lines = io.readfile("gettext-runtime/export.h")
        io.replace("gettext-runtime/intl/libgnuintl.h", "#define _LIBINTL_H 1", "#define _LIBINTL_H 1\n" .. lines, {plain = true})
        io.replace("gettext-runtime/intl/libgnuintl.h", "extern", "extern LIBINTL_DLL_EXPORTED", {plain = true})
    end)
    after_install(function (target)
        io.replace("gettext-runtime/intl/libintl.h", "extern", (target:is_plat("windows") and target:kind() == "shared") and "extern __declspec(dllimport)" or "extern", {plain = true})
        os.cp("gettext-runtime/intl/libintl.h", path.join(target:installdir(), "include", "libintl.h"))
    end)
target_end()
