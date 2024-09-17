package("jwasm")
    set_kind("binary")
    set_homepage("https://github.com/JWasm/JWasm")
    set_description("JWasm continuation")

    add_urls("https://github.com/JWasm/JWasm.git")
    add_versions("2022.12.25", "7218960b65d69216693a655d928eb4c2fb6b505c")

    on_install("@windows", "@linux", "@macosx", "@bsd", "@mingw", "@msys", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("jwasm")
                set_kind("binary")
                add_files("*.c")
                add_includedirs("H")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        -- os.vrun("jwasm -h") -- return 1
        assert(os.isexec(package:installdir("bin/jwasm") .. (is_host("windows") and ".exe" or "")))
    end)
