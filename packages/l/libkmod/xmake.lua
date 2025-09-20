package("libkmod")
    set_homepage("https://github.com/kmod-project/kmod")
    set_description("libkmod - Linux kernel module handling")
    set_license("LGPL-2.1")

    add_urls("https://github.com/kmod-project/kmod/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/kmod-project/kmod.git")

    add_versions("33", "c72120a2582ae240221671ddc1aa53ee522764806f50f8bf1522bbf055679985")
    add_versions("32", "9477fa096acfcddaa56c74b988045ad94ee0bac22e0c1caa84ba1b7d408da76e")
    add_versions("31", "16c40aaa50fc953035b4811b29ce3182f220e95f3c9e5eacb4b07b1abf85f003")
    add_versions("30", "1fa3974abd80b992d61324bcc04fa65ea96cfe2e9e1150f48394833030c4b583")

    add_patches(">=30 <33", path.join(os.scriptdir(), "patches", "31", "basename.patch"), "83d07e169882cc91f3af162912ae97cd4b62ff48876ca83b0317c40a388773ad")

    add_configs("zstd", {description = "Enable zstd support.", default = true, type = "boolean"})
    add_configs("zlib", {description = "Enable zlib support.", default = true, type = "boolean"})
    add_configs("xz", {description = "Enable xz support.", default = true, type = "boolean"})

    add_includedirs("include", "include/libkmod")
    on_load(function (package)
    on_load(function (package)
        for _, lib in ipairs({"zstd", "zlib", "xz"}) do
            if package:config(lib) then
                package:add("deps", lib)
            end
        end
    end)
    end)

    on_install("linux", "android", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        os.cp(path.join(package:scriptdir(), "port", "config.h"), "config.h")
        os.cp(path.join(package:scriptdir(), "port", "endian-darwin.h"), "endian-darwin.h")
        import("package.tools.xmake").install(package, {
            zstd = package:config("zstd"),
            zlib = package:config("zlib"),
            xz = package:config("xz"),
            ver = package:version_str()
        })
    end)

    on_test(function (package)
        assert(package:has_cfuncs("kmod_new", {includes = "libkmod/libkmod.h"}))
    end)
