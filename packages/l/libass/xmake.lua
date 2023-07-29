package("libass")
    set_homepage("https://github.com/libass/libass")
    set_description("libass is a portable subtitle renderer for the ASS/SSA (Advanced Substation Alpha/Substation Alpha) subtitle format.")
    set_license("ISC")

    add_urls("https://github.com/libass/libass/-/archive/$(version).tar.gz",
             "https://github.com/libass/libass.git")

    add_versions("0.17.1", "5ba42655d7e8c5e87bba3ffc8a2b1bc19c29904240126bb0d4b924f39429219f")

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
