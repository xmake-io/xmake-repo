package("faac")
    set_homepage("https://sourceforge.net/projects/faac/")
    set_description("Freeware Advanced Audio Coder faac mirror")
    set_license("LGPL-2.1")

    add_urls("https://github.com/knik0/faac/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return version:gsub("%.", "_")
    end})
    add_versions("1.30", "adc387ce588cca16d98c03b6ec1e58f0ffd9fc6eadb00e254157d6b16203b2d2")

    add_deps("autoconf", "automake", "libtool")

    on_install("linux", "macosx", "bsd", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:is_plat("linux") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("faacEncOpen", {includes = "faac.h"}))
    end)
