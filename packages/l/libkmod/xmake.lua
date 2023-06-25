package("libkmod")
    set_homepage("https://github.com/kmod-project/kmod")
    set_description("libkmod - Linux kernel module handling")
    set_license("LGPL-2.1")

    add_urls("https://github.com/kmod-project/kmod/archive/refs/tags/$(version).tar.gz",
             "https://github.com/kmod-project/kmod.git")
    add_versions("v30", "1fa3974abd80b992d61324bcc04fa65ea96cfe2e9e1150f48394833030c4b583")

    on_install("linux", "android", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        os.cp(path.join(package:scriptdir(), "port", "config.h"), "config.h")
        os.cp(path.join(package:scriptdir(), "port", "endian-darwin.h"), "endian-darwin.h")

        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("kmod_new", {includes = "libkmod/libkmod.h"}))
    end)
