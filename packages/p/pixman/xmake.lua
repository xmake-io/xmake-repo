package("pixman")

    set_homepage("https://cairographics.org/")
    set_description("Low-level library for pixel manipulation.")

    add_urls("https://gitlab.freedesktop.org/pixman/pixman/-/archive/eadb82866b0f6a326a61c36f60e5c2be8f7479af/pixman-eadb82866b0f6a326a61c36f60e5c2be8f7479af.tar.gz")
    add_versions("2021.12.17", "6dba7bc2d921082aa3bb4922fd19e6ce43d2ba8990549d1ea1596bec41d4461c")

    add_deps("meson", "ninja")

    add_includedirs("include/pixman-1")

    on_install("macosx", "linux", "windows", function (package)
        local configs = {
            "-Dtests=disabled",
            "-Dopenmp=disabled",
            "-Dlibpng=disabled",
            "-Dgtk=disabled"}
        table.insert(configs, "-Ddebug=" .. (package:debug() and "true" or "false"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pixman_image_create_solid_fill", {includes = "pixman.h"}))
    end)
