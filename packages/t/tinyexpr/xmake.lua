package("tinyexpr")

    set_homepage("https://codeplea.com/tinyexpr")
    set_description("TinyExpr is a very small parser and evaluation library for evaluating math expressions from C.")
    set_license("zlib")

    add_urls("https://github.com/codeplea/tinyexpr.git")
    add_versions("2022.11.21", "74804b8c5d296aad0866bbde6c27e2bc1d85e5f2")

    add_configs("pow_from_right", { description = "Use right-to-left exponentiation.", default = false, type = "boolean" })
    add_configs("natural_log", { description = "Let `log` default to the natural log instead of `log10`.", default = false, type = "boolean" })

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            
            option("pow_from_right", { showmenu = true, default = false })
            option("natural_log", { showmenu = true, default = false })

            target("tinyexpr")
                set_kind("static")
                add_files("tinyexpr.c")
                add_headerfiles("tinyexpr.h")

                if has_config("pow_from_right") then
                    add_defines("TE_POW_FROM_RIGHT")
                end

                if has_config("natural_log") then
                    add_defines("TE_NAT_LOG")
                end
        ]])
        
        local configs = {
            pow_from_right = package:config("pow_from_right"),
            natural_log = package:config("natural_log"),
        }
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("te_interp", {includes = "tinyexpr.h"}))
    end)
