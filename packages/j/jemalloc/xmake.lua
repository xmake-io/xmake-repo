package("jemalloc")

    set_homepage("http://jemalloc.net/")
    set_description([[A general purpose malloc(3) implementation that emphasizes
fragmentation avoidance and scalable concurrency support]])

    set_urls("https://github.com/jemalloc/jemalloc/releases/download/$(version)/jemalloc-$(version).tar.bz2",
             "https://github.com/jemalloc/jemalloc.git")

    add_versions("5.2.1", "34330e5ce276099e2e8950d9335db5a875689a4c6a56751ef3b1d8c537f887f6")

    add_patches("5.2.1", path.join(os.scriptdir(), "patches", "5.2.1", "fix_nothrow_type.patch"), "d79f5c8767695059ff541f291db3fbc57c9b67299dc129848dd365c2f51b214a")

    on_load(function (package)
        if package:gitref() then
            package:add("deps", "automake", "autoconf")
        end
    end)

    on_install(function(package)
        local configs = {"--disable-debug",
                         "--with-jemalloc-prefix="}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_plat("linux") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({
            test = [[
              #include <stdlib.h>
              #include <jemalloc/jemalloc.h>
              int main(void) {
                for (size_t i = 0; i < 1000; i++) {
                    malloc(i * 100);
                }
                malloc_stats_print(NULL, NULL, NULL);
              }
            ]]
        }, {includes = {"stdlib.h", "jemalloc/jemalloc.h"}}))
    end)
