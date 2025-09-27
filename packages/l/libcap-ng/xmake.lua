package("libcap-ng")
    set_homepage("https://github.com/stevegrubb/libcap-ng")
    set_description("Libcap-ng is a library for Linux that makes using posix capabilities easy.")

    add_urls("https://github.com/stevegrubb/libcap-ng/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stevegrubb/libcap-ng.git")
    add_versions("v0.8.5", "e4be07fdd234f10b866433f224d183626003c65634ed0552b02e654a380244c2")

    add_configs("utils", {description = "Build utilities.", default = true, type = "boolean"})

    add_deps("autotools")
    on_install("linux", function (package)
        local configs = {
            "--disable-dependency-tracking",
            "--without-python3"
        }
        table.insert(configs, "--with-debug=" .. (package:is_debug() and "yes" or "no"))

        local subdirs = {"src", "m4"}
        if package:config("utils") then
            table.insert(subdirs, "utils")
        end
        io.replace("Makefile.am", "SUBDIRS = src utils m4 docs", "SUBDIRS = " .. table.concat(subdirs, " "), {plain = true})
        io.replace("src/Makefile.am", "SUBDIRS = test", "SUBDIRS =", {plain = true})

        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("capng_setpid", {includes = "cap-ng.h"}))
    end)
