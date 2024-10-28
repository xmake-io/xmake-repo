package("klib")
    set_homepage("http://attractivechaos.github.io/klib/")
    set_description("A standalone and lightweight C library")
    set_license("MIT")

    add_urls("https://github.com/attractivechaos/klib.git")
    add_versions("2024.06.03", "29445495262cf34f4c3b82d3917ac83f3e1f3f58")

    add_configs("url", {description = "Enable FILE-like interfaces to libcurl.", default = false, type = "boolean"})
    add_configs("thread", {description = "Enable simple multi-threading models.", default = false, type = "boolean"})
    add_configs("open", {description = "Enable smart stream opening.", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end

    add_deps("zlib")

    on_load(function (package)
        if package:config("url") then
            package:add("deps", "libcurl")
        end
        if package:config("thread") then
            package:add("syslinks", "pthread")
        end
    end)

    on_install(function (package)
        io.replace("bgzf.c", "fp->uncompressed_block + input_length", "(char*)fp->uncompressed_block + input_length", {plain = true})
        io.replace("bgzf.c", "fp->compressed_block + 18", "(char*)fp->compressed_block + 18", {plain = true})
        io.replace("knetfile.c", "buf + l", "(char*)buf + l", {plain = true})
        if package:is_plat("windows", "mingw") then
            io.replace("khmm.c", "// new/delete hmm_par_t", [[#include "rand48.c"]], {plain = true})
        end

        local configs = {
            url = package:config("url"),
            thread = package:config("thread"),
            open = package:config("open"),
        }
        if package:is_plat("windows", "mingw") then
            os.cp(path.join(package:scriptdir(), "port", "rand48.c"), "rand48.c")
            if package:is_plat("windows") then
                os.cp(path.join(package:scriptdir(), "port", "unistd.h"), "unistd.h")
            end
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("kmalloc", {includes = "kalloc.h"}))
    end)
