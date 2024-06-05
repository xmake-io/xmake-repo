package("quirc")
    set_homepage("https://github.com/dlbeer/quirc")
    set_description("QR decoder library")

    add_urls("https://github.com/dlbeer/quirc.git")
    add_versions("2023.03.22", "542848dd6b9b0eaa9587bbf25b9bc67bd8a71fca")

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
