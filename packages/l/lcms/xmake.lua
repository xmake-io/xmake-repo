package("lcms")

    set_homepage("https://www.littlecms.com/")
    set_description("A free, open source, CMM engine.")
    set_license("MIT")

    add_urls("https://github.com/mm2/Little-CMS/archive/$(version).tar.gz")
    add_versions("2.11", "478c9c3938d7a91b1171de4616f8b04308a8676d73eadc19505b7ace41327f28")

    on_install("windows", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("lcms2")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_includedirs("include")
                add_headerfiles("include/(*.h)")
        ]])
        import("package.tools.xmake").install(package, {kind = package:config("shared") and "shared" or "static"})
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--with-pic"}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
            table.insert(configs, "--enable-static=no")
        else
            table.insert(configs, "--enable-static=yes")
            table.insert(configs, "--enable-shared=no")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cmsXYZ2xyY", {includes = "lcms2.h"}))
    end)
