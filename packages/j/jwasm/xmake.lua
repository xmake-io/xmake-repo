package("jwasm")
    set_kind("binary")
    set_homepage("https://github.com/JWasm/JWasm")
    set_description("JWasm continuation")
    set_license("JWasm")

    add_urls("https://github.com/JWasm/JWasm.git")
    add_versions("2025.01.10", "a5c4ea03cc0545a15d81a354251b5f534bef7a1b")

    on_install(function (package)
        if package:is_plat("mingw", "msys") then
            io.replace("memalloc.c", "#include <sys/mman.h>", "", {plain = true})
        end

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("jwasm")
                set_kind("binary")
                add_files("*.c|trmem.c")
                add_includedirs("H")
                add_defines("DEBUG_OUT")
                if is_plat("windows", "mingw", "msys") then
                    add_defines("__NT__")
                else
                    add_defines("__UNIX__")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        -- os.vrun("jwasm -h") -- return 1
        assert(os.isexec(path.join(package:installdir("bin"), "jwasm" .. (is_host("windows") and ".exe" or ""))))
    end)
