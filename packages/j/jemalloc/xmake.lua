package("jemalloc")
    set_homepage("https://jemalloc.net/")
    set_description("A general purpose malloc(3) implementation that emphasizes fragmentation avoidance and scalable concurrency support.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/jemalloc/jemalloc/releases/download/$(version)/jemalloc-$(version).tar.bz2",
             "https://github.com/jemalloc/jemalloc.git")

    add_versions("5.3.1", "3826bc80232f22ed5c4662f3034f799ca316e819103bdc7bb99018a421706f92")
    add_versions("5.3.0", "2db82d1e7119df3e71b7640219b6dfe84789bc0537983c3b7ac4f7189aecfeaa")
    add_versions("5.2.1", "34330e5ce276099e2e8950d9335db5a875689a4c6a56751ef3b1d8c537f887f6")

    add_patches("5.2.1", path.join(os.scriptdir(), "patches", "5.2.1", "fix_nothrow_type.patch"), "d79f5c8767695059ff541f291db3fbc57c9b67299dc129848dd365c2f51b214a")

    add_configs("prefix", {description = "Prefix to prepend to all public APIs", default = (is_plat("android") and "je_" or ""), type = "string"})
    add_configs("prof", {description = "Enable allocation profiling", default = false, type = "boolean"})
    if is_plat("mingw") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("linux", "cross", "bsd") then
        add_syslinks("pthread", "dl")
    end

    on_load(function (package)
        if package:gitref() then
            package:add("deps", "automake", "autoconf")
        end
        if package:is_plat("android") and package:config("prefix") == "je_" then
            wprint("package(jemalloc): set API prefix to \"je_\" on Android to avoid C++ declaration conflicts.")
        end
    end)

    on_install("linux", "cross", "macosx", "bsd", "android@linux", "mingw", function(package)
        if package:version() and package:version():ge("5.3.1") then
            io.replace("configure.ac", "AC_MSG_ERROR([cannot determine return type of strerror_r])", "", {plain = true})
            io.replace("configure", [[as_fn_error $? "cannot determine return type of strerror_r" "$LINENO" 5]], "", {plain = true})
        end
        local configs = {"--enable-doc=no"}
        local cflags = {}
        table.insert(configs, "--enable-debug=" .. (package:is_debug() and "yes" or "no"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--with-jemalloc-prefix=" .. package:config("prefix"))
        table.insert(configs, "--enable-prof=" .. (package:config("prof") and "yes" or "no"))
        if package:is_plat("android") then
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
        import("package.tools.autoconf").install(package, configs, {cflags = cflags})
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({test = [[
            int main() {
                ]] .. package:config("prefix") .. [[malloc_stats_print(NULL, NULL, NULL);
                return 0;
            }
        ]]}, {includes = {"jemalloc/jemalloc.h"}}))
    end)
