package("neco")
    set_homepage("https://github.com/tidwall/neco")
    set_description("Concurrency library for C (coroutines)")
    set_license("MIT")

    add_urls("https://github.com/tidwall/neco/archive/refs/tags/$(version).tar.gz",
             "https://github.com/tidwall/neco.git")

    add_versions("v0.3.2", "ae3cefa6217428e992da0b30f254502b9974079dd9973eee9c482ea89df3fcef")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl")
    elseif is_plat("mingw") then
        add_syslinks("ws2_32", "wsock32")
    end

    if on_check then
        on_check("windows", function (package)
            assert(package:has_cincludes("stdatomic.h", {configs = {languages = "c11"}}),
             "package(neco) Require at least C11 and stdatomic.h")
        end)
    end

    on_install("linux", "mingw|x86_64", "windows", "bsd", "android", "iphoneos", function (package)
        io.replace("neco.c", "#if defined(__linux__) && !defined(_GNU_SOURCE)",
            "#if defined(__linux__) && !defined(_GNU_SOURCE) && !defined(__ANDROID__)", {plain = true})
        io.replace("neco.c", "&(int){1}", "(const char*)&(int){1}", {plain = true})
        if package:is_plat("linux") then
            io.replace("neco.c", "#include <stdlib.h>", "#include <stdlib.h>\n#include <time.h>\n#include <sys/mman.h>", {plain = true})
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            set_warnings("none")
            set_languages("c11")
            target("neco")
                set_kind("$(kind)")
                add_files("neco.c")
                add_headerfiles("neco.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
                if is_plat("linux", "bsd") then
                    add_syslinks("pthread", "dl")
                    add_defines("_BSD_SOURCE")
                elseif is_plat("windows", "mingw") then
                    add_syslinks("ws2_32", "wsock32")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("neco_start", {includes = "neco.h"}))
    end)
