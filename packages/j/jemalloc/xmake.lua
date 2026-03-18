package("jemalloc")
    set_homepage("http://jemalloc.net/")
    set_description("A general purpose malloc(3) implementation that emphasizes fragmentation avoidance and scalable concurrency support.")

    add_urls("https://github.com/jemalloc/jemalloc/releases/download/$(version)/jemalloc-$(version).tar.bz2",
             "https://github.com/jemalloc/jemalloc.git")

    add_versions("5.3.0", "2db82d1e7119df3e71b7640219b6dfe84789bc0537983c3b7ac4f7189aecfeaa")
    add_versions("5.2.1", "34330e5ce276099e2e8950d9335db5a875689a4c6a56751ef3b1d8c537f887f6")

    add_patches("5.2.1", path.join(os.scriptdir(), "patches", "5.2.1", "fix_nothrow_type.patch"), "d79f5c8767695059ff541f291db3fbc57c9b67299dc129848dd365c2f51b214a")

    add_configs("prefix", {description = "Prefix to prepend to all public APIs", default = "", type = "string"})
    add_configs("prof", {description = "Enable allocation profiling", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl")
    end

    on_load(function (package)
        if package:gitref() then
            package:add("deps", "automake", "autoconf")
        end
        if package:is_plat("android") then
            package:add("defines", "JEMALLOC_STRERROR_R_RETURNS_CHAR_WITH_GNU_SOURCE")
        end
    end)

    on_install("linux", "macosx", "bsd", "android", "mingw", function(package)
        local configs = {"--enable-doc=no"}
        table.insert(configs, "--enable-debug=" .. (package:is_debug() and "yes" or "no"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--with-jemalloc-prefix=" .. (package:config("prefix") or ""))
        table.insert(configs, "--enable-prof=" .. (package:config("prof") and "yes" or "no"))
        import("package.tools.autoconf").install(package, configs)
        if package:is_plat("mingw") and package:config("shared") then
            os.trymv(package:installdir("lib", "*.dll"), package:installdir("bin"))
        end
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({
            test = [[
                int main() {
                    malloc_stats_print(NULL, NULL, NULL);
                }
            ]]
        }, {includes = {"jemalloc/jemalloc.h"}}))
    end)
