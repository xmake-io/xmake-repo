package("libass")
    set_homepage("https://github.com/libass/libass")
    set_description("libass is a portable subtitle renderer for the ASS/SSA (Advanced Substation Alpha/Substation Alpha) subtitle format.")
    set_license("ISC")

    add_urls("https://github.com/libass/libass/releases/download/$(version)/libass-$(version).tar.gz",
             "https://github.com/libass/libass.git")

    add_versions("0.17.3", "da7c348deb6fa6c24507afab2dee7545ba5dd5bbf90a137bfe9e738f7df68537")
    add_versions("0.15.2", "1b2a54dda819ef84fa2dee3069cf99748a886363d2adb630fde87fe046e2d1d5")
    add_versions("0.16.0", "fea8019b1887cab9ab00c1e58614b4ec2b1cee339b3f7e446f5fab01b032d430")
    add_versions("0.17.0", "72b9ba5d9dd1ac6d30b5962f38cbe7aefb180174f71d8b65c5e3c3060dbc403f")
    add_versions("0.17.1", "d653be97198a0543c69111122173c41a99e0b91426f9e17f06a858982c2fb03d")

    add_deps("freetype", "fribidi", "harfbuzz", "nasm")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        os.cp(path.join(package:scriptdir(), "port", "config.h.in"), "config.h.in")
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ass_library_init", {includes = "ass.h"}))
    end)
