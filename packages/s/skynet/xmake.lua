package("skynet")

    set_kind("binary")
    set_homepage("https://github.com/cloudwu/skynet")
    set_description("A lightweight online game framework")
    set_license("MIT")

    add_urls("https://github.com/cloudwu/skynet/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cloudwu/skynet.git")
    add_versions("v1.5.0", "5f36fe92346dfe0502c05421287d7964d63ccb189d78f5835a0e4f01995ea9fa")

    on_install("macosx", "linux", "bsd", function (package)
        local configs = {}
        if package:is_plat("macosx") then
            table.insert(configs, "macosx")
        elseif package:is_plat("bsd") then
            table.insert(configs, "freebsd")
        else
            table.insert(configs, "linux")
        end
        import("package.tools.make").build(package, configs)
        os.vcp("3rd/lua/lua", package:installdir("bin", "skylua"))
        os.vcp("skynet", package:installdir("bin"))
        os.vcp("lualib", package:installdir("lib"))
        os.vcp("luaclib", package:installdir("lib"))
        os.vcp("cservice", package:installdir("lib"))
    end)

    on_test(function (package)
        os.vrun("skylua -v")
    end)
