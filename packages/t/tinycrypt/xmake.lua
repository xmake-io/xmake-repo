package("tinycrypt")
    set_homepage("https://github.com/intel/tinycrypt")
    set_description("TinyCrypt Cryptographic Library")

    add_urls("https://github.com/intel/tinycrypt.git")
    add_versions("2019.9.18", "5969b0e0f572a15ed95dc272e57104faeb5eb6b0")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("tinycrypt")
               set_kind("$(kind)")
               add_files("lib/source/*.c")
               add_includedirs("lib/include")
               add_headerfiles("lib/include/(**.h)")
               if is_plat("windows") and is_kind("shared") then
                   add_rules("utils.symbols.export_all")
               end
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        if package:is_plat("windows", "mingw") then
            io.replace("lib/include/tinycrypt/ecc_platform_specific.h", "#define default_RNG_defined 1", "#define default_RNG_defined 0", {plain = true})
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tc_aes_encrypt", {includes = "tinycrypt/aes.h"}))
    end)
