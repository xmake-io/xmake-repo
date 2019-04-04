package("pixman")

    set_homepage("https://cairographics.org/")
    set_description("Low-level library for pixel manipulation.")

    set_urls("https://cairographics.org/releases/pixman-$(version).tar.gz")

    add_versions("0.38.0", "a7592bef0156d7c27545487a52245669b00cf7e70054505381cff2136d890ca8")

    if not is_plat("windows") then
        add_deps("pkg-config")
        add_includedirs("include/pixman-1")
    end

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package, {"--disable-dependency-tracking", "--disable-gtk", "--disable-silent-rules"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pixman_image_create_solid_fill", {includes = "pixman.h"}))
    end)
