package("cairo")

    set_homepage("https://cairographics.org/")
    set_description("Vector graphics library with cross-device output support.")

    set_urls("https://cairographics.org/releases/cairo-$(version).tar.xz")
    add_versions("1.16.0", "5e7b29b3f113ef870d1e3ecf8adf21f923396401604bda16d44be45e66052331")

    add_deps("libpng", "pixman", "zlib", "freetype")
    if is_plat("linux") then
        add_deps("fontconfig")
    end

    if is_plat("windows") then
        add_syslinks("gdi32", "msimg32", "user32")
    elseif is_plat("macosx") then
        add_frameworks("CoreGraphics", "CoreFoundation")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load("windows", function (package)
        if not package:config("shared") then 
            package:add("defines", "CAIRO_WIN32_STATIC_BUILD=1")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        os.cp(path.join(package:scriptdir(), "port", "cairo-features.h.in"), "cairo-features.h")
        io.replace("cairo-features.h", "${FC_ON}", (package:is_plat("linux") and "1" or "0"), {plain = true})
        import("package.tools.xmake").install(package, {kind = package:config("shared") and "shared" or "static"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cairo_create", {includes = "cairo/cairo.h"}))
    end)
