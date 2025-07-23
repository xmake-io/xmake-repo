package("zimg")
    set_homepage("https://github.com/sekrit-twc/zimg")
    set_description("Scaling, colorspace conversion, and dithering library")
    set_license("WTFPL")

    add_urls("https://github.com/sekrit-twc/zimg/archive/refs/tags/release-$(version).tar.gz")
    add_versions("3.0.3", "5e002992bfe8b9d2867fdc9266dc84faca46f0bfd931acc2ae0124972b6170a7")
    add_versions("3.0.5", "a9a0226bf85e0d83c41a8ebe4e3e690e1348682f6a2a7838f1b8cbff1b799bcf")

    add_deps("autoconf", "automake", "libtool")

    on_install("macosx", "linux", "bsd", function (package)
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
        assert(package:has_cfuncs("zimg_image_format_default", {includes = "zimg.h"}))
    end)
