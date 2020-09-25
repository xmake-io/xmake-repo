package("pixman")

    set_homepage("https://cairographics.org/")
    set_description("Low-level library for pixel manipulation.")

    set_urls("https://cairographics.org/releases/pixman-$(version).tar.gz")
    add_versions("0.38.0", "a7592bef0156d7c27545487a52245669b00cf7e70054505381cff2136d890ca8")

    if is_plat("windows") then
        add_deps("make")
    else
        add_deps("pkg-config")
    end
    add_includedirs("include/pixman-1")

    on_install("windows", function (package)
        io.gsub("Makefile.win32.common", "%-MD", "-" .. package:config("vs_runtime"))
        os.vrun("make -f Makefile.win32 pixman MMX=off")
        os.cp("pixman/*.h", package:installdir("include/pixman-1"))
        os.cp("pixman/release/*.lib", package:installdir("lib"))
    end)

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package, {"--disable-dependency-tracking", "--disable-gtk", "--disable-silent-rules"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pixman_image_create_solid_fill", {includes = "pixman.h"}))
    end)
