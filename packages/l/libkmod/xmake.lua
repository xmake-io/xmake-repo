package("libkmod")
    set_homepage("https://github.com/kmod-project/kmod")
    set_description("libkmod - Linux kernel module handling")
    set_license("LGPL-2.1")

    add_urls("https://github.com/kmod-project/kmod/archive/refs/tags/$(version).tar.gz",
             "https://github.com/kmod-project/kmod.git")

    add_versions("v31", "16c40aaa50fc953035b4811b29ce3182f220e95f3c9e5eacb4b07b1abf85f003")
    add_versions("v30", "1fa3974abd80b992d61324bcc04fa65ea96cfe2e9e1150f48394833030c4b583")

    add_patches("31", path.join(os.scriptdir(), "patches", "31", "basename.patch"), "83d07e169882cc91f3af162912ae97cd4b62ff48876ca83b0317c40a388773ad")

    on_install("linux", "android", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        os.cp(path.join(package:scriptdir(), "port", "config.h"), "config.h")
        os.cp(path.join(package:scriptdir(), "port", "endian-darwin.h"), "endian-darwin.h")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("kmod_new", {includes = "libkmod/libkmod.h"}))
    end)
