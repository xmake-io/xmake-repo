package("awk")
    set_kind("binary")
    set_homepage("https://github.com/onetrueawk/awk")
    set_description("One true awk")
    set_license("MIT-Lucent")

    add_urls("https://github.com/onetrueawk/awk/archive/refs/tags/$(version).tar.gz", 
             "https://github.com/onetrueawk/awk.git")

    add_versions("20251225", "626d7d19f8e4ceae70f60e2e662291789e0f54ab86945317a3d5693c30f847a2")

    add_deps("bison")

    on_install("@linux", "@macosx", "@bsd", function (package)
        os.vrun("bison -d awkgram.y")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("maketab")
                set_kind("binary")
                add_files("maketab.c")
                set_plat(os.host())
                set_arch(os.arch())
                after_build(function (target)
                    os.vrunv(target:targetfile(), {"awkgram.tab.h"}, {stdout = "proctab.c", curdir = os.projectdir()})
                end)
        ]])
        os.vrun(os.programfile())

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("awk")
                set_kind("binary")
                add_files("*.c|maketab.c")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        os.vrun("awk --version")
    end)
