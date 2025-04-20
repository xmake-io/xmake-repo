set_project("libiconv")

add_rules("mode.debug", "mode.release")

set_configvar("PACKAGE", "libiconv")
set_configvar("PACKAGE_NAME", "libiconv")
set_configvar("PACKAGE_TARNAME", "libiconv")
set_configvar("PACKAGE_BUGREPORT", "")
set_configvar("PACKAGE_URL", "")

option("relocatable")
    set_default(true)
    set_showmenu(true)
    set_configvar("ENABLE_RELOCATABLE", 1)
option_end()
add_options("relocatable")

option("installprefix")
    set_default("")
    set_showmenu(true)
option_end()
set_configvar("INSTALLPREFIX", get_config("installprefix"))

option("vers")
    set_default("")
    set_showmenu(true)
option_end()
if has_config("vers") then
    set_configvar("VERSION", get_config("vers"))
    set_configvar("PACKAGE_VERSION", get_config("vers"))
    set_configvar("PACKAGE_STRING", "libiconv " .. get_config("vers"))
end

includes("@builtin/check")

-- config.h variables
option("__NO_BROKEN_WCHAR_H")
    set_showmenu(false)
    add_csnippets("wchar.h", [[#include <wchar.h>
wchar_t w;]])
option_end()
set_configvar("BROKEN_WCHAR_H", has_config("__NO_BROKEN_WCHAR_H") and 0 or 1)
option("GNULIB_STRERROR")
    set_showmenu(false)
    add_csnippets("strerror", [[#include <string.h>
int test() { if (!*strerror(-2)) { return 1; } return 0; }]])
    set_configvar("GNULIB_STRERROR", 1)
option_end()
add_options("GNULIB_STRERROR")
configvar_check_cfuncs("HAVE_ICONV", "iconv", {includes = "iconv.h"})
option("ICONV_NO_CONST")
    set_showmenu(false)
    add_csnippets("ICONV_NO_CONST", [[#include <iconv.h>
extern
#ifdef __cplusplus
"C"
#endif
#if defined(__STDC__) || defined(_MSC_VER) || defined(__cplusplus)
size_t iconv (iconv_t cd, char * *inbuf, size_t *inbytesleft, char * *outbuf, size_t *outbytesleft);
#else
size_t iconv();
#endif]])
option_end()
set_configvar("ICONV_CONST", (has_config("HAVE_ICONV") and not has_config("ICONV_NO_CONST")) and "const" or "", {quote = false})

set_configvar("LT_OBJDIR", ".libs/")
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
set_configvar("STDC_HEADERS", 1)
set_configvar("USE_UNLOCKED_IO", 1)
set_configvar("WORDS_LITTLEENDIAN", 1)
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
if not is_plat("android", "iphoneos") then
    set_configvar("ssize_t", "int", {quote = false})
    set_configvar("uid_t", "int", {quote = false})
end
configvar_check_ctypes("USE_MBSTATE_T", "mbstate_t", {includes = "wchar.h", default = 0})
configvar_check_cincludes("ENABLE_NLS", "libintl.h", {default = 0})
configvar_check_cincludes("HAVE_DLFCN_H", "dlfcn.h")
configvar_check_cincludes("HAVE_FCNTL", "fcntl.h")
configvar_check_cincludes("HAVE_INTTYPES_H", "inttypes.h")
configvar_check_cincludes("HAVE_MACH_O_DYLD_H", "mach-o/dyld.h")
configvar_check_cincludes("HAVE_MEMORY_H", "memory.h")
configvar_check_cincludes("HAVE_STDINT_H", "stdint.h")
configvar_check_cincludes("HAVE_STDLIB_H", "stdlib.h")
configvar_check_cincludes("HAVE_STRINGS_H", "strings.h")
configvar_check_cincludes("HAVE_STRING_H", "string.h")
configvar_check_cincludes("HAVE_SYS_STAT_H", "sys/stat.h")
configvar_check_cincludes("HAVE_SYS_TYPES_H", "sys/types.h")
configvar_check_cincludes("HAVE_UNISTD_H", "unistd.h")
configvar_check_cincludes("HAVE_ALLOCA_H", "alloca.h")
configvar_check_cincludes("HAVE_SEARCH_H", "search.h")
configvar_check_cincludes("HAVE_SYS_BITYPES_H", "sys/bitypes.h")
configvar_check_cfuncs("HAVE__NSGETEXECUTABLEPATH", "_NSGetExecutablePath")
configvar_check_cfuncs("HAVE_MSVC_INVALID_PARAMETER_HANDLER", "_set_invalid_parameter_handler")
configvar_check_cfuncs("HAVE_SETLOCALE", "setlocale", {includes = "locale.h"})
configvar_check_cfuncs("HAVE_SYMLINK", "symlink", {includes = "unistd.h"})
configvar_check_cfuncs("GNULIB_FSCANF", "fscanf", {includes = "stdio.h"})
configvar_check_cfuncs("GNULIB_SCANF", "scanf", {includes = "stdio.h"})
configvar_check_cfuncs("HAVE_ALLOCA", "alloca", {includes = "alloca.h"})
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
configvar_check_cfuncs("HAVE_GETCWD", "getcwd", {includes = "unistd.h"})
configvar_check_cfuncs("HAVE_GETEXECNAME", "getexecname", {includes = "stdlib.h"})
configvar_check_cfuncs("HAVE_GETPROGNAME", "getprogname", {includes = "stdlib.h"})
configvar_check_ctypes("HAVE_LONG_LONG_INT", "long long int")
configvar_check_ctypes("HAVE_UNSIGNED_LONG_LONG_INT", "unsigned long long int")
configvar_check_ctypes("HAVE__BOOL", "_Bool")
configvar_check_cfuncs("HAVE_LSTAT", "lstat", {includes = "sys/stat.h"})
configvar_check_cfuncs("HAVE_MALLOC_POSIX", "malloc", {includes = "stdlib.h"})
configvar_check_cfuncs("HAVE_MBRTOWC", "mbrtowc", {includes = "wchar.h"})
configvar_check_cfuncs("HAVE_WCRTOMB", "wcrtomb", {includes = "wchar.h"})
configvar_check_cfuncs("HAVE_MBSINIT", "mbsinit", {includes = "wchar.h"})
configvar_check_cfuncs("HAVE_RAISE", "raise", {includes = "signal.h"})
configvar_check_cfuncs("HAVE_READLINK", "readlink", {includes = "unistd.h"})
configvar_check_cfuncs("HAVE_READLINKAT", "readlinkat", {includes = "unistd.h"})
configvar_check_cfuncs("HAVE_REALPATH", "realpath", {includes = "stdlib.h"})
configvar_check_cfuncs("FUNC_REALPATH_WORKS", "realpath", {includes = "stdlib.h"})
configvar_check_cfuncs("HAVE_TSEARCH", "tsearch", {includes = "search.h"})
configvar_check_ctypes("HAVE_WCHAR_T", "wchar_t", {includes = "wchar.h"})
configvar_check_ctypes("HAVE_SIGSET_T", "sigset_t", {includes = "signal.h"})
configvar_check_csnippets("HAVE_VISIBILITY", [[
extern __attribute__((__visibility__("hidden"))) int hiddenvar;
extern __attribute__((__visibility__("default"))) int exportedvar;
extern __attribute__((__visibility__("hidden"))) int hiddenfunc(void);
extern __attribute__((__visibility__("default"))) int exportedfunc(void);]], {default = 0})
configvar_check_csnippets("HAVE__ARGV", [[#include <stdlib.h>
#ifndef __argv
(void) __argv;
#endif]], {default = 0})
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
int test() { char* cs = nl_langinfo(CODESET); return !cs; }]], {links = "c"})
configvar_check_csnippets("HAVE_ENVIRON_DECL=0", [[extern struct {int foo;} environ;
void test() {environ.foo = 1;}]], {includes = has_config("__HAVE_UNISTD_H") and "unistd.h" or "stdlib.h", default = 1})

target("charset")
    set_kind("$(kind)")
    add_defines("HAVE_CONFIG_H")
    if is_kind("shared") then
        add_defines("BUILDING_LIBCHARSET")
    end
    set_configdir("libcharset")
    add_configfiles("libcharset/(include/localcharset.h.build.in)", {filename = "localcharset.h", pattern = "@(.-)@"})
    add_configfiles("libcharset/(include/libcharset.h.in)", {filename = "libcharset.h", pattern = "@(.-)@"})
    add_configfiles("libcharset/(config.h.in)", {filename = "config.h"})
    add_includedirs("libcharset/include", "libcharset")
    add_files("libcharset/lib/localcharset.c")
    after_install(function (target)
        os.cp("libcharset/include/libcharset.h.in", path.join(target:installdir(), "include", "libcharset.h"))
        os.cp("libcharset/include/localcharset.h.in", path.join(target:installdir(), "include", "localcharset.h"))
    end)
target_end()

target("iconv")
    set_kind("$(kind)")
    add_deps("charset", {inherit = false})
    add_defines("HAVE_CONFIG_H", "NO_XMALLOC", "IN_LIBRARY")
    if is_kind("shared") then
        add_defines("BUILDING_LIBICONV", "BUILDING_DLL")
    end
    set_configdir(".")
    set_configvar("DLL_VARIABLE", (is_plat("windows") and is_kind("shared")) and "__declspec(dllimport)" or "")
    add_configfiles("(include/iconv.h.build.in)", {filename = "iconv.h", pattern = "@(.-)@", variables = {EILSEQ = ""}})
    add_configfiles("(include/iconv.h.in)", {filename = "iconv.h.inst", pattern = "@(.-)@", variables = {EILSEQ = ""}})
    add_configfiles("(config.h.in)", {filename = "config.h"})
    add_includedirs(".", "lib", "include", "libcharset/include", {public = true})
    add_files("lib/iconv.c", "lib/relocatable.c", "libcharset/lib/localcharset.c")
    after_install(function (target)
        os.cp("include/iconv.h.inst", path.join(target:installdir(), "include", "iconv.h"))
        for _, name in ipairs(os.files("po/*.gmo")) do
            local locale = path.basename(name)
            os.cp(name, path.join(target:installdir(), "share", "locale", locale, "LC_MESSAGES", "libiconv.mo"))
        end
    end)
target_end()

target("icrt")
    set_kind("static")
    add_includedirs(".", "srclib", {public = true})
    set_configdir(".")
    add_configfiles("(srclib/uniwidth.in.h)", {filename = "uniwidth.h"})
    add_configfiles("(srclib/unitypes.in.h)", {filename = "unitypes.h"})
    add_files("srclib/progname.c", "srclib/safe-read.c", "srclib/uniwidth/width.c")
    if has_config("relocatable") then
        add_files("srclib/progreloc.c", "srclib/relocatable.c")
    end
    add_defines("EXEEXT=\"" .. (is_plat("windows") and ".exe" or "") .. "\"")
    on_install(function (target) end) -- disable installation

target("iconv_no_i18n")
    set_kind("binary")
    add_deps("iconv", "icrt")
    if has_config("installprefix") then
        add_defines("INSTALLDIR=\"" .. path.join(get_config("installprefix"), "bin"):gsub("\\", "\\\\") .. "\"")
        add_defines("LOCALEDIR=\"" .. path.join(get_config("installprefix"), "share", "locale"):gsub("\\", "\\\\") .. "\"")
    end
    add_files("src/iconv_no_i18n.c")

    if is_plat("android", "iphoneos") then
        -- Gnulib defines these macros to 0 on GNU and other platforms that do not distinguish between text and binary I/O.
        -- https://www.gnu.org/software/gnulib/manual/html_node/fcntl_002eh.html
        add_defines("O_BINARY=0")
    end
