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

includes("@builtin/check")

-- Helper: func checks
local function check_funcs(...)
    for _, t in ipairs({...}) do
        local var, fn, inc = t[1], t[2], t[3]
        if inc then
            configvar_check_cfuncs(var, fn, {includes = inc})
        else
            configvar_check_cfuncs(var, fn)
        end
    end
end

-- Used autoconf variables
set_configvar("_GNU_SOURCE", 1)
set_configvar("__USE_MINGW_ANSI_STDIO", 1)
configvar_check_cincludes("ENABLE_NLS", "libintl.h", {default = 0})	
check_funcs(
    {"HAVE_GETCWD", "getcwd", "unistd.h"},
    {"HAVE_MBRTOWC", "mbrtowc", "wchar.h"},
    {"HAVE_WCRTOMB", "wcrtomb", "wchar.h"},
    {"HAVE_WCSLEN", "wcslen", "wchar.h"},
    {"HAVE_WCWIDTH", "wcwidth", "wchar.h"},
    {"HAVE_WCSNLEN", "wcsnlen", "wchar.h"},
    {"HAVE_STPCPY", "stpcpy", "string.h"},
    {"HAVE_MEMPCPY", "mempcpy", "string.h"},
    {"HAVE_MMAP", "mmap", "sys/mman.h"},
    {"HAVE_MUNMAP", "munmap", "sys/mman.h"}
)
configvar_check_ctypes("HAVE_WINT_T", "wint_t", {includes = "wchar.h"})
configvar_check_csnippets("HAVE_VISIBILITY", [[
extern __attribute__((__visibility__("hidden"))) int hiddenvar;
extern __attribute__((__visibility__("default"))) int exportedvar;
extern __attribute__((__visibility__("hidden"))) int hiddenfunc(void);
extern __attribute__((__visibility__("default"))) int exportedfunc(void);]], {default = 0})
configvar_check_csnippets("GNULIB_SIGPIPE", [[#include <signal.h>
#ifndef SIGPIPE
#error SIGPIPE not defined
#endif]])
configvar_check_csnippets("HAVE_LANGINFO_CODESET", [[#include <langinfo.h>
int test() { char* cs = nl_langinfo(CODESET); return !cs; }]])

-- config.h variables
if is_plat("windows", "mingw") then
    set_configvar("USE_WINDOWS_THREADS", 1)
elseif is_plat("bsd") then
    set_configvar("USE_POSIX_THREADS", 1)
else
    option("USE_ISOC_THREADS")
        add_cfuncs("thrd_create")
        add_cincludes("threads.h")
    option_end()
    if has_config("USE_ISOC_THREADS") then
        set_configvar("USE_ISOC_AND_POSIX_THREADS", 1)
    else
        set_configvar("USE_POSIX_THREADS", 1)
    end
end
configvar_check_ctypes("HAVE_STDINT_H_WITH_UINTMAX", "uintmax_t", {includes = "stdint.h"})
configvar_check_cincludes("HAVE_STDINT_H", "stdint.h")
if is_plat("android") then
    configvar_check_cfuncs("HAVE_PTHREAD_API", "pthread_create", {includes = "pthread.h"})
else
    configvar_check_links("HAVE_PTHREAD_API", "pthread")
end
configvar_check_ctypes("HAVE_PTHREAD_RWLOCK", "pthread_rwlock_t", {includes = "pthread.h"})
if not is_plat("windows", "mingw") then
    configvar_check_csnippets("HAVE_PTHREAD_MUTEX_RECURSIVE", [[#include <pthread.h>
int test() { int x = PTHREAD_MUTEX_RECURSIVE; return !x; }]])
    if not is_plat("macosx") then
        configvar_check_csnippets("HAVE_WEAK_SYMBOLS", [[__attribute__((__weak__)) void *f(void);]], {default = 0})
    end
    configvar_check_cincludes("HAVE_THREADS_H", "threads.h")
    configvar_check_cincludes("HAVE_SYS_SINGLE_THREADED_H", "sys/single_threaded.h")
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
set_configvar("HAVE_ALLOCA_H", 0)
configvar_check_csnippets("HAVE_SAME_LONG_DOUBLE_AS_DOUBLE", [[
#include <float.h>
int test() {
  int same = sizeof(long double) == sizeof(double)
    && LDBL_MANT_DIG == DBL_MANT_DIG
    && LDBL_MAX_EXP == DBL_MAX_EXP
    && LDBL_MIN_EXP == DBL_MIN_EXP;
  return same;
}]])
configvar_check_csnippets("HAVE_FREE_POSIX", [[
#if !(__GLIBC__ >= 2 || defined __OpenBSD__ || defined __sun)
#error not a known-good platform
#endif
void test() {}]])	
configvar_check_csnippets("FLEXIBLE_ARRAY_MEMBER=/**/", [[
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
struct m { struct m *next, **list; char name[]; };
struct s { struct s *p; struct m *m; int n; double d[]; };
int test() {
  int m = getchar();
  size_t nbytes = offsetof(struct s, d) + m * sizeof(double);
  nbytes += sizeof(struct s) - 1;
  nbytes -= nbytes % sizeof(struct s);
  struct s *p = malloc(nbytes);
  p->p = p;
  p->m = NULL;
  p->d[0] = 0.0;
  return p->d != (double *)NULL;
}
]], {default = 1, quote = false})
configvar_check_csnippets("HAVE_WORKING_USELOCALE", [[
#include <locale.h>
locale_t loc1;
void test() {
  uselocale(NULL);
  setlocale(LC_ALL, "en_US.UTF-8");
}
]])
if is_plat("windows", "mingw") then
    set_configvar("WOE32DLL", is_kind("shared") and 1 or 0)
else
    set_configvar("WOE32DLL", 0)
end
set_configvar("SETLOCALE_NULL_ALL_MTSAFE", is_plat("windows", "linux") and 1 or 0)
set_configvar("SETLOCALE_NULL_ONE_MTSAFE", 1)
configvar_check_cincludes("HAVE_SEARCH_H", "search.h")
configvar_check_cincludes("HAVE_STDBOOL_H", "stdbool.h")
configvar_check_cincludes("HAVE_UNISTD_H", "unistd.h")
configvar_check_cincludes("HAVE_XLOCALE_H", "xlocale.h")

if is_plat("macosx") then
    set_configvar("HAVE_GOOD_USELOCALE", 1)
end

if is_plat("android") then
    local ndk_sdkver = get_config("ndk_sdkver")
    if ndk_sdkver and tonumber(ndk_sdkver) >= 23 then
        set_configvar("HAVE_MEMPCPY", 1)
    end
end

-- search.h variables
set_configvar("GUARD_PREFIX", "GL", {quote = false})
set_configvar("PRAGMA_SYSTEM_HEADER", "", {quote = false})
set_configvar("PRAGMA_COLUMNS", "", {quote = false})
if is_plat("windows", "mingw") then
    set_configvar("INCLUDE_NEXT", "include", {quote = false})
    set_configvar("NEXT_SEARCH_H", "<search.h>", {quote = false})
else
    set_configvar("INCLUDE_NEXT", "include_next", {quote = false})
    set_configvar("NEXT_SEARCH_H", "<search.h>", {quote = false})
end
set_configvar("GNULIB_MDA_LFIND", 1)
set_configvar("GNULIB_MDA_LSEARCH", 1)
configvar_check_ctypes("HAVE_TYPE_VISIT", "VISIT", {includes = "search.h", default = 0})
option("HAVE_TSEARCH")
    add_cfuncs("tsearch")
    add_cincludes("search.h")
option_end()
option("HAVE_TWALK")
    add_cfuncs("twalk")
    add_cincludes("search.h")
option_end()
if has_config("HAVE_TSEARCH") and has_config("HAVE_TWALK") then
    set_configvar("HAVE_TSEARCH", 1)
    set_configvar("HAVE_TWALK", 1)
    set_configvar("REPLACE_TSEARCH", 0)
    set_configvar("REPLACE_TWALK", 0)
    set_configvar("GNULIB_TSEARCH", 0)
else
    set_configvar("tsearch", "_libintl_tsearch", {quote = false})
    set_configvar("tfind", "_libintl_tfind", {quote = false})
    set_configvar("tdelete", "_libintl_tdelete", {quote = false})
    set_configvar("twalk", "_libintl_twalk", {quote = false})
    set_configvar("rpl_tsearch", "_libintl_tsearch", {quote = false})
    set_configvar("rpl_tfind", "_libintl_tfind", {quote = false})
    set_configvar("rpl_tdelete", "_libintl_tdelete", {quote = false})
    set_configvar("rpl_twalk", "_libintl_twalk", {quote = false})
    set_configvar("HAVE_TSEARCH", 0)
    set_configvar("HAVE_TWALK", 0)
    set_configvar("REPLACE_TSEARCH", 1)
    set_configvar("REPLACE_TWALK", 1)
    set_configvar("GNULIB_TSEARCH", 1)
end

-- libgnuintl.h variables
set_configvar("HAVE_NAMELESS_LOCALES", 0)
set_configvar("ENHANCE_LOCALE_FUNCS", 0)
configvar_check_cfuncs("HAVE_NEWLOCALE", "newlocale", {includes = (is_plat("macosx", "bsd") and "xlocale.h" or "locale.h"), default = 0})
configvar_check_cfuncs("HAVE_POSIX_PRINTF", "printf", {includes = "stdio.h", default = 0})
configvar_check_cfuncs("HAVE_WPRINTF", "wprintf", {includes = "wchar.h", default = 0})
configvar_check_cfuncs("HAVE_SNPRINTF", "snprintf", {includes = "stdio.h", default = 0})
configvar_check_cfuncs("HAVE_ASPRINTF", "asprintf", {includes = "stdio.h", default = 0})

target("intl")
    set_kind("$(kind)")
    add_defines("HAVE_CONFIG_H", "NO_XMALLOC", "IN_LIBRARY", "BUILDING_LIBRARY", "IN_LIBINTL")
    if is_kind("shared") then
        add_defines("BUILDING_LIBINTL", "BUILDING_DLL")
        if is_plat("windows", "mingw") then
            add_defines("DLL_EXPORT")
        end
    end
    if is_plat("windows", "mingw") then
        add_syslinks("advapi32")
    elseif is_plat("bsd") then
        add_syslinks("pthread")
    end

    if is_plat("mingw") and is_kind("shared") then
      add_ldflags("-Wl,--export-all-symbols")
    end

    set_configvar("HAVE_ICONV", 0)
    set_configvar("HAVE_ICONV_H", 0)
    add_defines("DEPENDS_ON_LIBICONV=0")
    set_configdir("gettext-runtime/intl")
    add_configfiles("gettext-runtime/intl/(libgnuintl.in.h)", {filename = "libgnuintl.h", pattern = "@(.-)@"})
    add_configfiles("gettext-runtime/intl/(export.h)", {filename = "export.h", pattern = "@(.-)@"})
    add_configfiles("gettext-runtime/intl/(gnulib-lib/search.in.h)", {filename = "tsearch.h", pattern = "@(.-)@"})
    add_configfiles("gettext-runtime/intl/gnulib-lib/(alloca.in.h)", {filename = "alloca.h", pattern = "@(.-)@"})
    add_includedirs("gettext-runtime/intl", "gettext-runtime/intl/gnulib-lib")
    add_files("gettext-runtime/intl/*.c")
    add_files("gettext-runtime/intl/gnulib-lib/*.c")
    add_files("gettext-runtime/intl/gnulib-lib/glthread/*.c")

    remove_files("gettext-runtime/intl/os2compat.c")
    remove_files("gettext-runtime/intl/intl-exports.c")
    remove_files("gettext-runtime/intl/gnulib-lib/c32*.c")
    remove_files("gettext-runtime/intl/gnulib-lib/frexp*.c")
    remove_files("gettext-runtime/intl/gnulib-lib/getcwd-lgpl.c")
    remove_files("gettext-runtime/intl/gnulib-lib/pthread-once.c")
    remove_files("gettext-runtime/intl/gnulib-lib/unistd.c")
    remove_files("gettext-runtime/intl/gnulib-lib/localeconv.c")
    remove_files("gettext-runtime/intl/gnulib-lib/memchr.c")
    remove_files("gettext-runtime/intl/gnulib-lib/strncpy.c")
    remove_files("gettext-runtime/intl/gnulib-lib/wmemcpy.c")
    remove_files("gettext-runtime/intl/gnulib-lib/wmemset.c")
    remove_files("gettext-runtime/intl/gnulib-lib/iswblank.c")
    remove_files("gettext-runtime/intl/gnulib-lib/iswdigit.c")
    remove_files("gettext-runtime/intl/gnulib-lib/iswpunct.c")
    remove_files("gettext-runtime/intl/gnulib-lib/iswxdigit.c")
    remove_files("gettext-runtime/intl/gnulib-lib/mbsinit.c")
    remove_files("gettext-runtime/intl/gnulib-lib/stdio-consolesafe.c")
    remove_files("gettext-runtime/intl/gnulib-lib/wcwidth.c")
    remove_files("gettext-runtime/intl/gnulib-lib/mbrtoc32.c")
    remove_files("gettext-runtime/intl/gnulib-lib/isnan.c")
    remove_files("gettext-runtime/intl/gnulib-lib/mbchar.c")
    remove_files("gettext-runtime/intl/gnulib-lib/mbiterf.c")
    remove_files("gettext-runtime/intl/gnulib-lib/mbsnlen.c")
    if not is_plat("macosx") then
        remove_files("gettext-runtime/intl/gnulib-lib/getlocalename_l-unsafe.c")
    end
    if not is_plat("windows", "mingw") then
        remove_files("gettext-runtime/intl/gnulib-lib/windows-*.c")
    end
    before_build(function (target)
        -- Generate config.h from config.h.in, with extra patches
        local src = path.join(os.projectdir(), "gettext-runtime/intl/config.h.in")
        local dst = path.join(target:configdir(), "config.h")
        local cvars = target:get("configvar") or {}
        for _, opt in ipairs(target:orderopts()) do
            for k, v in pairs(opt:get("configvar") or {}) do
                if cvars[k] == nil then cvars[k] = v end
            end
        end
        local content = io.readfile(src)
        content = content:gsub("@(.-)@", function(name)
            local v = cvars[name]
            if v == nil then return "@"..name.."@" end
            return (type(v) == "number" and tostring(v)) or
                   (type(v) == "boolean" and (v and "1" or "0")) or v
        end)
        content = content:gsub("#undef%s+([%w_]+)", function(name)
            local v = cvars[name]
            if v == nil or (type(v) == "boolean" and not v) then
                return "/* #undef "..name.." */"
            end
            local val = (type(v) == "number" and tostring(v)) or
                        (type(v) == "boolean" and "1") or v
            if type(v) == "string" then
                local extra = target:extraconf("configvar." .. name, v)
                if not extra or extra.quote ~= false then
                    val = '"' .. val .. '"'
                end
            end
            return "#define "..name.." "..val
        end)
        content = content:gsub("%$%{define ([%w_]+)}", function(name)
            local v = cvars[name]
            if v == nil or (type(v) == "boolean" and not v) then
                return "/* #undef " .. name .. " */"
            end
            local val = (type(v) == "number" and tostring(v)) or
                        (type(v) == "boolean" and "1") or v
            if type(v) == "string" then
                local extra = target:extraconf("configvar." .. name, v)
                if not extra or extra.quote ~= false then
                    val = '"' .. val .. '"'
                end
            end
            return "#define " .. name .. " " .. val
        end)
        if not content:find("SETLOCALE_NULL_ALL_MAX", 1, true) then
            content = content .. "\n\n#ifndef SETLOCALE_NULL_ALL_MAX\n#define SETLOCALE_NULL_ALL_MAX (148+12*256+1)\n#define SETLOCALE_NULL_MAX (256+1)\n#endif\n"
        end
        if not content:find("\\n#define locale_t", 1, true) then
            if is_plat("windows", "mingw") then
                content = content .. "\n#ifndef locale_t\n#define locale_t _locale_t\n#endif\n"
            elseif is_plat("macosx") then
                content = content .. "\n#include <xlocale.h>\n"
            end
        end
        if not content:find("\\nextern wchar_t", 1, true) and is_plat("mingw") then
            content = content .. [[
#include <stddef.h>
extern wchar_t *wgetcwd (wchar_t *, size_t);
]]
        end
        content = content .. "\n#include \"setlocale_null.h\"\n"
        if not content:find("\\n#define streq", 1, true) then
            content = content .. [[
#ifndef streq
#define streq(s1, s2) (strcmp((s1), (s2)) == 0)
#endif
#ifndef memeq
#define memeq(s1, s2, n) (memcmp((s1), (s2), (n)) == 0)
#endif
#ifndef mbszero
#include <string.h>
#define mbszero(ps) memset((ps), 0, sizeof(mbstate_t))
#endif
]]
        end
        content = content:gsub("#define mbszero%s+_libintl_mbszero\n",
            "#define mbszero(ps) memset((ps), 0, sizeof(mbstate_t))\n")
        io.writefile(dst, content)

        io.gsub("gettext-runtime/intl/gnulib-lib/tsearch.h", "(definitions of _GL_FUNCDECL_RPL etc.-)\n", "%1\n#include <c++defs.h>\n")
        io.gsub("gettext-runtime/intl/gnulib-lib/tsearch.h", "(definition of _GL_ARG_NONNULL.-)\n", "%1\n#include <arg-nonnull.h>\n")
        io.gsub("gettext-runtime/intl/gnulib-lib/tsearch.h", "(definition of _GL_WARN_ON_USE.-)\n", "%1\n#include <warn-on-use.h>\n")
        io.replace("gettext-runtime/intl/gnulib-lib/tsearch.c", "#include <search.h>", "#include <tsearch.h>", {plain = true})
        os.cp("gettext-runtime/intl/libgnuintl.h", "gettext-runtime/intl/libintl.h")

        local lines = io.readfile("gettext-runtime/intl/export.h")
        lines = lines:gsub("@WOE32DLL@", is_plat("windows", "mingw") and "1" or "0")
        lines = lines:gsub("@HAVE_VISIBILITY@", "0")
        io.replace("gettext-runtime/intl/libgnuintl.h", "#define _LIBINTL_H 1",
            "#define _LIBINTL_H 1\n" .. lines, {plain = true})
        io.replace("gettext-runtime/intl/libgnuintl.h", 'extern "C"', 'EXTERN_C', {plain = true})
        io.replace("gettext-runtime/intl/libgnuintl.h", "extern", "extern LIBINTL_SHLIB_EXPORTED", {plain = true})
        io.replace("gettext-runtime/intl/libgnuintl.h", 'EXTERN_C', 'extern "C"', {plain = true})
    end)
    after_install(function (target)
        local dest = path.join(target:installdir(), "include", "libintl.h")
        os.cp("gettext-runtime/intl/libintl.h", dest)
    end)
target_end()
