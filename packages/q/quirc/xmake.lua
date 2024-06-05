package("quirc")
    set_homepage("https://github.com/dlbeer/quirc")
    set_description("QR decoder library")

    add_urls("https://github.com/dlbeer/quirc/archive/refs/tags/v1.2.tar.gz",
             "https://github.com/dlbeer/quirc.git")
    add_versions("v1.2", "73c12ea33d337ec38fb81218c7674f57dba7ec0570bddd5c7f7a977c0deb64c5")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("quirc")
                set_kind("$(kind)")
                add_files("lib/*.c")
                add_headerfiles("lib/(*.h)")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("quirc_new", {includes = "quirc.h"}))
    end)
