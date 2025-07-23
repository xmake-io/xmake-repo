package("libaco")

    set_homepage("https://github.com/hnes/libaco")
    set_description("A blazing fast and lightweight C asymmetric coroutine library")
    set_license("Apache-2.0")

    add_urls("https://github.com/hnes/libaco/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hnes/libaco.git")

    add_versions("v1.2.4", "25e0777ec2c686cc8c8433537d9b3694d196b0287abe6df4f0c21f8605fa5a06")

    on_install("macosx", "linux", function (package)
        io.writefile("xmake.lua", [[
        add_rules("mode.debug", "mode.release")

        target("libaco")
            set_kind("$(kind)")
            add_files("acosw.S")
            add_headerfiles("aco.h")
            add_files("aco.c")
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aco_resume", {includes = "aco.h"}))
    end)
