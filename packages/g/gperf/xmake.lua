package("gperf")
    set_kind("binary")
    set_homepage("https://www.gnu.org/software/gperf")
    set_description("Perfect hash function generator.")
    set_license("GPL-3.0-or-later")

    set_urls("https://ftpmirror.gnu.org/gnu/gperf/gperf-$(version).tar.gz",
             "https://ftp.gnu.org/gnu/gperf/gperf-$(version).tar.gz")

    add_versions("3.1", "588546b945bba4b70b6a3a616e80b4ab466e3f33024a352fc2198112cdbb3ae2")
    add_versions("3.2.1", "ed5ad317858e0a9badbbada70df40194002e16e8834ac24491307c88f96f9702")

    if is_host("linux") then
        add_extsources("apt::gperf", "pacman::gperf")
    end

    on_install("@windows", function (package)
        os.cp("src/config.h.in", "src/config.h")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("gperf")
                set_kind("binary")
                add_files("lib/*.c", "lib/*.cc", "src/*.cc")
                add_includedirs("lib", "src")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_install("@macosx", "@linux", "@bsd", "@msys", function (package)
        io.replace("lib/getline.cc", "register", "", {plain = true})
        io.replace("lib/getopt.h", "#ifdef __GNU_LIBRARY__", "#if 1", {plain = true})
        io.replace("lib/getopt.c", "register", "", {plain = true})
        io.replace("lib/getopt.c", "extern char *getenv ();", "#include <stdlib.h>", {plain = true})
        io.replace("lib/getopt.c", "extern int strncmp ();", "#include <string.h>", {plain = true})
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        os.vrun("gperf --version")
    end)
