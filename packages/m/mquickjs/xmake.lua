package("mquickjs")
    set_homepage("https://github.com/bellard/mquickjs")
    set_description("Public repository of the Micro QuickJS Javascript Engine")

    add_urls("https://github.com/bellard/mquickjs.git")
    add_versions("2025.12.22", "17ce6fe54c1ea4f500f26636bd22058fce2ce61a")

    if is_plat("linux", "macosx", "bsd") then
        add_syslinks("m")
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install(function (package)
        io.replace("mquickjs.h", "#include <inttypes.h>", "#include <inttypes.h>\n#include <stddef.h>", {plain = true})
        io.replace("libm.c", "#define NDEBUG", "", {plain = true})
        os.cp("cutils.h", "cutils_host.h")
        io.replace("mqjs_stdlib.c", "cutils.h", "cutils_host.h", {plain = true})
        io.replace("mquickjs_build.c", "cutils.h", "cutils_host.h", {plain = true})

        -- Add MSVC compat definitions
        local msvc_compat = [[
#ifdef _MSC_VER
#include <intrin.h>
#include <sys/timeb.h>
#include <time.h>

#define likely(x) (x)
#define unlikely(x) (x)
#define force_inline __forceinline
#define no_inline __declspec(noinline)
#define __maybe_unused
#define __attribute__(x)

/* Type-generic macros for overflow checking */
#define __builtin_add_overflow(a, b, res) \
    ((sizeof(a) == 8) ? _add_overflow_u64((uint64_t)(a), (uint64_t)(b), (uint64_t*)(res)) : \
                        _add_overflow_u32((uint32_t)(a), (uint32_t)(b), (uint32_t*)(res)))

#define __builtin_sub_overflow(a, b, res) \
    ((sizeof(a) == 8) ? _sub_overflow_u64((uint64_t)(a), (uint64_t)(b), (uint64_t*)(res)) : \
                        _sub_overflow_u32((uint32_t)(a), (uint32_t)(b), (uint32_t*)(res)))

static inline int _add_overflow_u64(uint64_t a, uint64_t b, uint64_t *res) {
    *res = a + b;
    return (*res < a);
}

static inline int _add_overflow_u32(uint32_t a, uint32_t b, uint32_t *res) {
    *res = a + b;
    return (*res < a);
}

static inline int _sub_overflow_u64(uint64_t a, uint64_t b, uint64_t *res) {
    *res = a - b;
    return (a < b);
}

static inline int _sub_overflow_u32(uint32_t a, uint32_t b, uint32_t *res) {
    *res = a - b;
    return (a < b);
}

static inline int __builtin_clzll(uint64_t x) {

#ifdef _WIN64
    unsigned long idx;
    if (_BitScanReverse64(&idx, x)) return 63 - idx;
    return 64;
#else
    unsigned long idx;
    if (_BitScanReverse(&idx, (uint32_t)(x >> 32))) return 31 - idx;
    if (_BitScanReverse(&idx, (uint32_t)x)) return 63 - idx;
    return 64;
#endif
}
static inline int __builtin_clz(unsigned int x) {
    unsigned long idx;
    if (_BitScanReverse(&idx, x)) return 31 - idx;
    return 32;
}
static inline int __builtin_ctzll(uint64_t x) {
#ifdef _WIN64
    unsigned long idx;
    if (_BitScanForward64(&idx, x)) return idx;
    return 64;
#else
    unsigned long idx;
    if (_BitScanForward(&idx, (uint32_t)x)) return idx;
    if (_BitScanForward(&idx, (uint32_t)(x >> 32))) return 32 + idx;
    return 64;
#endif
}
static inline int __builtin_ctz(unsigned int x) {
    unsigned long idx;
    if (_BitScanForward(&idx, x)) return idx;
    return 32;
}

#if !defined(_WINSOCK2API_) && !defined(_WINSOCKAPI_)
struct timeval {
    long tv_sec;
    long tv_usec;
};
#endif

static int gettimeofday(struct timeval *tp, void *tzp) {
    struct __timeb64 t;
    _ftime64(&t);
    tp->tv_sec = (long)t.time;
    tp->tv_usec = t.millitm * 1000;
    return 0;
}
#endif
]]
        if is_host("windows") then
            -- Fix packed structs
            io.replace("cutils_host.h", "struct __attribute__%(%(packed%)%) (packed_u%d+) {\n%s+(uint%d+_t) v;\n};",
                "#ifdef _MSC_VER\n#pragma pack(push, 1)\nstruct %1 {\n    %2 v;\n};\n#pragma pack(pop)\n#else\nstruct __attribute__((packed)) %1 {\n    %2 v;\n};\n#endif")

            io.replace("cutils_host.h", "#include <inttypes.h>", "#include <inttypes.h>\n" .. msvc_compat, {plain = true})

            -- Prevent redefinition of macros
            io.replace("cutils_host.h", "(#define likely%(x%).-)\n", "#ifndef likely\n%1\n#endif\n")
            io.replace("cutils_host.h", "(#define unlikely%(x%).-)\n", "#ifndef unlikely\n%1\n#endif\n")
            io.replace("cutils_host.h", "(#define force_inline.-)\n", "#ifndef force_inline\n%1\n#endif\n")
            io.replace("cutils_host.h", "(#define no_inline.-)\n", "#ifndef no_inline\n%1\n#endif\n")
            io.replace("cutils_host.h", "(#define __maybe_unused.-)\n", "#ifndef __maybe_unused\n%1\n#endif\n")
        end
        if package:is_plat("windows", "mingw") then
            -- Fix packed structs
            io.replace("cutils.h", "struct __attribute__%(%(packed%)%) (packed_u%d+) {\n%s+(uint%d+_t) v;\n};",
                "#ifdef _MSC_VER\n#pragma pack(push, 1)\nstruct %1 {\n    %2 v;\n};\n#pragma pack(pop)\n#else\nstruct __attribute__((packed)) %1 {\n    %2 v;\n};\n#endif")

            io.replace("cutils.h", "#include <inttypes.h>", "#include <inttypes.h>\n" .. msvc_compat, {plain = true})

            -- Prevent redefinition of macros
            io.replace("cutils.h", "(#define likely%(x%).-)\n", "#ifndef likely\n%1\n#endif\n")
            io.replace("cutils.h", "(#define unlikely%(x%).-)\n", "#ifndef unlikely\n%1\n#endif\n")
            io.replace("cutils.h", "(#define force_inline.-)\n", "#ifndef force_inline\n%1\n#endif\n")
            io.replace("cutils.h", "(#define no_inline.-)\n", "#ifndef no_inline\n%1\n#endif\n")
            io.replace("cutils.h", "(#define __maybe_unused.-)\n", "#ifndef __maybe_unused\n%1\n#endif\n")

            -- Fix sys/time.h include in dtoa.c and other files
            io.replace("dtoa.c", "#include <sys/time.h>", "#ifndef _MSC_VER\n#include <sys/time.h>\n#endif", {plain = true})
            io.replace("mquickjs.c", "#include <sys/time.h>", "#ifndef _MSC_VER\n#include <sys/time.h>\n#endif", {plain = true})
            io.replace("libm.c", "#include <sys/time.h>", "#ifndef _MSC_VER\n#include <sys/time.h>\n#endif", {plain = true})
            io.replace("mqjs.c", "#include <sys/time.h>", "#ifndef _MSC_VER\n#include <sys/time.h>\n#endif", {plain = true})
            io.replace("readline_tty.c", "#include <sys/time.h>", "#ifndef _MSC_VER\n#include <sys/time.h>\n#endif", {plain = true})

            -- Fix void* arithmetic in mquickjs.c
            io.replace("mquickjs.c", "ctx->stack_top = mem_start + mem_size;", "ctx->stack_top = (uint8_t *)mem_start + mem_size;", {plain = true})

            -- Fix dump_token attribute syntax
            io.replace("mquickjs.c", "__attribute((unused)) dump_token", "dump_token", {plain = true})

            -- Fix case range syntax (GCC extension)
            io.replace("mquickjs.c", "case 'a' ... 'z':", "case 'a': case 'b': case 'c': case 'd': case 'e': case 'f': case 'g': case 'h': case 'i': case 'j': case 'k': case 'l': case 'm': case 'n': case 'o': case 'p': case 'q': case 'r': case 's': case 't': case 'u': case 'v': case 'w': case 'x': case 'y': case 'z':", {plain = true})
            io.replace("mquickjs.c", "case 'A' ... 'Z':", "case 'A': case 'B': case 'C': case 'D': case 'E': case 'F': case 'G': case 'H': case 'I': case 'J': case 'K': case 'L': case 'M': case 'N': case 'O': case 'P': case 'Q': case 'R': case 'S': case 'T': case 'U': case 'V': case 'W': case 'X': case 'Y': case 'Z':", {plain = true})
            io.replace("mquickjs.c", "case '1' ... '9':", "case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':", {plain = true})
            io.replace("readline.c", "case '0' ... '9':", "case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':", {plain = true})

            -- Fix incomplete array type for parse_func_table
            io.replace("mquickjs.c", "static JSParseFunc *parse_func_table[];", "static JSParseFunc *parse_func_table[16];", {plain = true})

            -- Fix void function returning value warnings/errors
            io.replace("mquickjs.c", "return JS_PrintValueF(ctx, val, 0);", "JS_PrintValueF(ctx, val, 0);", {plain = true})
            io.replace("mquickjs.c", "return js_parse_error(s, \"not enough memory\");", "js_parse_error(s, \"not enough memory\");", {plain = true})
            io.replace("mquickjs.c", "return js_parse_error(s, \"stack overflow\");", "js_parse_error(s, \"stack overflow\");", {plain = true})
            io.replace("mquickjs.c", "return js_parse_error(s, \"expecting '%c'\", c);", "js_parse_error(s, \"expecting '%c'\", c);", {plain = true})

            -- Fix division by zero constant expression (error C2124)
            io.replace("mquickjs.c", "return __JS_NewFloat64(ctx, is_max ? -1.0 / 0.0 : 1.0 / 0.0);", "return __JS_NewFloat64(ctx, is_max ? -HUGE_VAL : HUGE_VAL);", {plain = true})
            io.replace("mquickjs.c", "return __JS_NewFloat64(ctx, is_max ? -INFINITY : INFINITY);", "return __JS_NewFloat64(ctx, is_max ? -HUGE_VAL : HUGE_VAL);", {plain = true})
        end

        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")

            set_policy("build.fence", true)

            target("mqjs_stdlib_gen")
                set_kind("binary")
                set_plat(os.host())
                set_arch(os.arch())
                add_files("mqjs_stdlib.c", "mquickjs_build.c")
                add_defines("_GNU_SOURCE")

            target("mquickjs")
                set_kind("$(kind)")
                add_deps("mqjs_stdlib_gen")
                add_files("mquickjs.c", "libm.c", "dtoa.c", "cutils.c")
                add_headerfiles("mquickjs.h")
                add_defines("_GNU_SOURCE")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
                if is_plat("linux", "macosx", "bsd") then
                    add_syslinks("m")
                end
                before_build(function (target)
                    local mqjs_stdlib_gen = target:dep("mqjs_stdlib_gen"):targetfile()
                    local flags = {}
                    if not target:is_arch64() then
                        table.insert(flags, "-m32")
                    end
                    os.vrunv(mqjs_stdlib_gen, table.join({"-a"}, flags), {stdout = "mquickjs_atom.h"})
                    os.vrunv(mqjs_stdlib_gen, flags, {stdout = "mqjs_stdlib.h"})

                    -- Patch mqjs_stdlib.h for MSVC compatibility
                    if is_plat("windows", "mingw") then
                        io.replace("mqjs_stdlib.h", "static const uint64_t __attribute%(%(aligned%(64%)%)%) js_stdlib_table%[%]", "__declspec(align(64)) static const uint64_t js_stdlib_table[]", {plain = false})
                        io.replace("mqjs_stdlib.h", "static const uint32_t __attribute%(%(aligned%(64%)%)%) js_stdlib_table%[%]", "__declspec(align(64)) static const uint32_t js_stdlib_table[]", {plain = false})
                        -- Fix zero-sized array error (C2466)
                        io.replace("mqjs_stdlib.h", "static const JSCFinalizer js_c_finalizer_table[JS_CLASS_COUNT - JS_CLASS_USER] = {", "static const JSCFinalizer js_c_finalizer_table[(JS_CLASS_COUNT - JS_CLASS_USER) > 0 ? (JS_CLASS_COUNT - JS_CLASS_USER) : 1] = {", {plain = true})

                        -- Fix missing Windows headers and sleep function in mqjs.c
                        io.replace("mqjs.c", "#include <fcntl.h>", "#include <fcntl.h>\n#ifdef _WIN32\n#include <windows.h>\n#endif", {plain = true})
                        io.replace("mqjs.c", "nanosleep(&ts, NULL);", "#ifdef _WIN32\nSleep(min_delay);\n#else\nnanosleep(&ts, NULL);\n#endif", {plain = true})

                        if is_plat("windows") then
                            -- Export utf8 helper functions in cutils.c
                            io.replace("cutils.c", "size_t __unicode_to_utf8(uint8_t *buf, unsigned int c)", "__declspec(dllexport) size_t __unicode_to_utf8(uint8_t *buf, unsigned int c)", {plain = true})
                            io.replace("cutils.c", "int __utf8_get(const uint8_t *p, size_t *plen)", "__declspec(dllexport) int __utf8_get(const uint8_t *p, size_t *plen)", {plain = true})

                            -- Add dllexport to declarations in cutils.h to match definitions
                            io.replace("cutils.h", "size_t __unicode_to_utf8(uint8_t *buf, unsigned int c);", "__declspec(dllexport) size_t __unicode_to_utf8(uint8_t *buf, unsigned int c);", {plain = true})
                            io.replace("cutils.h", "int __utf8_get(const uint8_t *p, size_t *plen);", "__declspec(dllexport) int __utf8_get(const uint8_t *p, size_t *plen);", {plain = true})
                        end
                    end
                end)

            target("mqjs")
                set_kind("binary")
                add_files("mqjs.c", "readline.c")
                add_files("readline_tty.c")
                add_deps("mquickjs")
                add_deps("mqjs_stdlib_gen")
                add_includedirs(".")
        ]])
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("JS_NewContext", {includes = "mquickjs.h"}))
        if not package:is_cross() then
            os.vrun("mqjs -e \"var a = 1; console.log(a);\"")
        end
    end)


