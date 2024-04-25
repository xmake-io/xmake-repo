package("cello")
    set_homepage("http://libcello.org/")
    set_description("Higher level programming in C")

    add_urls("https://github.com/orangeduck/Cello/archive/refs/tags/$(version).tar.gz",
             "https://github.com/orangeduck/Cello.git")

    add_versions("2.1.0", "c138d974325fcb9640307c8b2d5dcc2d7127a1ccc5589d6c0794f86a5cb4001d")

    if is_plat("windows", "mingw") then
        add_syslinks("dbghelp")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_install(function(package)
        local opt = {}
        if package:has_cincludes("execinfo.h") then
            if package:has_cincludes("execinfo.h", {configs = {syslinks = "execinfo"}}) then
                opt.ldflags = "-lexecinfo"
                package:add("syslinks", "execinfo")
            end
        else
            opt.cxflags = "-DCELLO_NSTRACE"
            package:add("defines", "CELLO_NSTRACE")
        end

        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("cello")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_headerfiles("include/Cello.h")
                add_includedirs("include")

                if is_plat("windows", "mingw") then
                    add_syslinks("dbghelp")
                    if is_kind("shared") then
                        add_rules("utils.symbols.export_all")
                    end
                elseif is_plat("linux", "bsd") then
                    add_syslinks("pthread")
                end
        ]])
        import("package.tools.xmake").install(package, {}, opt)
    end)

    on_test(function(package)
        assert(package:has_cfuncs("name", {includes = "Cello.h"}))
    end)
