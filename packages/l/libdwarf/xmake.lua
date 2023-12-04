package("libdwarf")

    set_kind("library")
    set_homepage("https://www.prevanders.net/dwarf.html")
    set_description("Libdwarf is a C library intended to simplify reading (and writing) applications using DWARF2, DWARF3, DWARF4 and DWARF5")

    add_urls("https://www.prevanders.net/libdwarf-$(version).tar.xz")
    add_versions("0.8.0", "771814a66b5aadacd8381b22d8a03b9e197bd35c202d27e19fb990e9b6d27b17")

    add_deps("cmake")

    on_install("linux", "macosx", "mingw", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_NON_SHARED=" .. (package:config("shared") and "OFF" or "ON"))

        import("package.tools.cmake").install(package, configs)
        os.cp(path.join("src", "lib", "libdwarf", "*.h"), path.join(package:installdir("include"), "libdwarf"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "libdwarf/libdwarf.h"
            #include "libdwarf/libdwarf_private.h"
            #include <stddef.h>
            #include "libdwarf/dwarf_string.h"

            void test() {
                    struct dwarfstring_s g;
                    char *d = 0;
                    const char *expstr = "";
                    int res = 0;
                    unsigned long biglen = 0;
                    const char *bigstr = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
                        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
                        "ccccccbbbbbbbbbbbbbbbbbbbbbccc"
                        "ccccccbbbbbbbbbbbbbbbbbbbbbccc"
                        "ccccccbbbbbbbbbbbbbbbbbbbbbccc"
                        "ccccccbbbbbyyyybbbbbbbbbbbbccc";
                    const char *mediumstr = "1234567890aaaaabbbbbb0123";

                    dwarfstring_constructor(&g);
            }
        ]]}))
    end)
