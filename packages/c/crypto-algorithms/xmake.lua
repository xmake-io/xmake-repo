package("crypto-algorithms")
    set_homepage("https://github.com/KorewaWatchful/crypto-algorithms")
    set_description("Basic implementations of standard cryptography algorithms, like AES and SHA-1.")

    add_urls("https://github.com/KorewaWatchful/crypto-algorithms.git")
    add_versions("2020.4.20", "cb9ea3fada60f9b01e9133d7db4d3e08171d0565")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("crypto-algorithms")
                set_kind("$(kind)")
                add_files("*.c")
                remove_files("*_test.c")
                add_headerfiles("*.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("base64_encode", {includes = "base64.h"}))
    end)
