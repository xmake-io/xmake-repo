package("jemalloc")
    set_homepage("http://jemalloc.net/")
    set_description("A general purpose malloc(3) implementation that emphasizes fragmentation avoidance and scalable concurrency support.")

    add_urls("https://github.com/jemalloc/jemalloc/releases/download/$(version)/jemalloc-$(version).tar.bz2",
             "https://github.com/jemalloc/jemalloc.git")

    add_versions("5.3.0", "2db82d1e7119df3e71b7640219b6dfe84789bc0537983c3b7ac4f7189aecfeaa")
    add_versions("5.2.1", "34330e5ce276099e2e8950d9335db5a875689a4c6a56751ef3b1d8c537f887f6")

    add_patches("5.2.1", path.join(os.scriptdir(), "patches", "5.2.1", "fix_nothrow_type.patch"), "d79f5c8767695059ff541f291db3fbc57c9b67299dc129848dd365c2f51b214a")

    add_configs("prefix", {description = "Prefix to prepend to all public APIs", default = (is_plat("android") and "je_" or ""), type = "string"})
    add_configs("prof", {description = "Enable allocation profiling", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl")
    end

    on_load(function (package)
        if package:gitref() then
            package:add("deps", "automake", "autoconf")
        end
        if package:is_plat("android") and package:config("prefix") == "je_" then
            wprint("package(jemalloc): set API prefix to \"je_\" on Android to avoid C++ declaration conflicts.")
        end
        if package:is_plat("mingw") and package:config("shared") then
            package:add("links", "jemalloc")
        end
    end)

    on_install("linux", "macosx", "bsd", "android", "mingw", function(package)
        local configs = {"--enable-doc=no"}
        local cflags = {}
        table.insert(configs, "--enable-debug=" .. (package:is_debug() and "yes" or "no"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--with-jemalloc-prefix=" .. package:config("prefix"))
        table.insert(configs, "--enable-prof=" .. (package:config("prof") and "yes" or "no"))
        if package:is_plat("android") then
            if is_host("windows") then
                table.insert(configs, "--disable-libdl")
                table.insert(cflags, "-UWIN32")
                table.insert(cflags, "-U_WIN32")
                table.insert(cflags, "-UWIN64")
                table.insert(cflags, "-U_WIN64")
                io.replace("include/jemalloc/internal/jemalloc_internal_decls.h",
                    "#ifdef _WIN32",
                    "#if defined(_WIN32) && !defined(__ANDROID__) && !defined(__linux__)", {plain = true})
            else
                local has_gnu_strerror_r, _ = package:check_csnippets({test = [[
                    #define _GNU_SOURCE 1
                    #include <errno.h>
                    #include <stdio.h>
                    #include <stdlib.h>
                    #include <string.h>
                    int main() {
                        char *buffer = (char *) malloc(100);
                        char *error = strerror_r(EINVAL, buffer, 100);
                        printf("%s\n", error);
                    }
                ]]})
                if has_gnu_strerror_r then
                    table.insert(cflags, "-DJEMALLOC_STRERROR_R_RETURNS_CHAR_WITH_GNU_SOURCE")
                end
            end
        end
        import("package.tools.autoconf").install(package, configs, {cflags = cflags})
        if package:is_plat("mingw") and package:config("shared") then
            os.trymv(package:installdir("lib", "jemalloc.dll"), package:installdir("bin", "libjemalloc.dll"))
            os.vexecv("ls", {package:installdir("lib/lib")})
        end
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({test = [[
            int main() {
                ]] .. package:config("prefix") .. [[malloc_stats_print(NULL, NULL, NULL);
                return 0;
            }
        ]]}, {includes = {"jemalloc/jemalloc.h"}}))
    end)
