add_rules("mode.debug", "mode.release")
add_requires("libcurl", "gmp", "icu4c", "mpfr", "readline", "libxml2")
add_packages("libcurl", "gmp", "icu4c", "mpfr", "readline", "libxml2")
add_includedirs(".", "libqalculate")
set_languages("c++17")

includes("@builtin/check")
check_cxxincludes("HAVE_UNORDERED_MAP", "unordered_map")
check_cincludes("HAVE_PTHREADS", "pthread.h")
check_cincludes("HAVE_STDIO_H", "stdio.h")
check_cfuncs("HAVE_PIPE2", "pipe2", {includes = {"unistd.h", "fcntl.h"}})
-- External dependencies
check_cincludes("HAVE_ICONV", "iconv.h")
check_cincludes("HAVE_ICU", "unicode/ucasemap.h")
check_cincludes("HAVE_LIBCURL", "curl/curl.h")
check_cincludes("HAVE_LIBREADLINE", {"stdio.h", "readline/readline.h"})
-- Check if 'int_n_cs_precedes' is a member of 'struct lconv'
check_csnippets("HAVE_STRUCT_LCONV_INT_N_CS_PRECEDES", [[
    #include <locale.h>
    void* test(void) {
        return &((struct lconv *)0)->int_n_cs_precedes;
    }
]])
check_csnippets("HAVE_STRUCT_LCONV_INT_P_CS_PRECEDES", [[
    #include <locale.h>
    void* test(void) {
        return &((struct lconv *)0)->int_p_cs_precedes;
    }
]])
-- Define "ICONV_CONST" as "const" if the declaration of iconv() needs const.
option("iconv_not_need_const")
    add_csnippets("iconv_const", [[
        #include <iconv.h>
        #include <string.h>

        #ifndef ICONV_CONST
        # define ICONV_CONST 
        #endif
        int main(int argc, char **argv) {
            int result = 0;
            /* Test against AIX 5.1 bug: Failures are not distinguishable from successful
               returns.  */
            iconv_t cd_utf8_to_88591 = iconv_open("ISO8859-1", "UTF-8");
            if (cd_utf8_to_88591 != (iconv_t)(-1)) {
                static ICONV_CONST char input[] = "\342\202\254"; /* EURO SIGN */
                char buf[10];
                ICONV_CONST char *inptr = input;
                size_t inbytesleft = strlen(input);
                char *outptr = buf;
                size_t outbytesleft = sizeof(buf);
                size_t res = iconv(cd_utf8_to_88591,
                                    &inptr, &inbytesleft,
                                    &outptr, &outbytesleft);
                if (res == 0)
                    result |= 1;
                iconv_close(cd_utf8_to_88591);
            }
            return result;
        }
    ]])
option_end()
if get_config("iconv_not_need_const") then
    add_defines("ICONV_CONST=")
else
    add_defines("ICONV_CONST=const")
end

option("version", {default = "0.0.1"})
local version = get_config("version")
if version then
    add_defines("VERSION=\"" .. version .. "\"")
end

target("libqalculate") -- Expect `libqalculate.pc` to be generated
    set_basename("qalculate")
    set_kind("$(kind)")
    add_headerfiles("(libqalculate/BuiltinFunctions.h)",
                    "(libqalculate/Calculator.h)",
                    "(libqalculate/DataSet.h)",
                    "(libqalculate/ExpressionItem.h)",
                    "(libqalculate/Function.h)",
                    "(libqalculate/MathStructure.h)",
                    "(libqalculate/Number.h)",
                    "(libqalculate/Prefix.h)",
                    "(libqalculate/QalculateDateTime.h)",
                    "(libqalculate/Unit.h)",
                    "(libqalculate/Variable.h)",
                    "(libqalculate/includes.h)",
                    "(libqalculate/qalculate.h)",
                    "(libqalculate/util.h)")
    add_files("libqalculate/*.cc")

target("qalc")
    set_kind("binary")
    add_files("src/qalc.cc")
    add_deps("libqalculate")
