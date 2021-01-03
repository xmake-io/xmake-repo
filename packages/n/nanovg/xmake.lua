package("nanovg")

    set_homepage("https://github.com/memononen/nanovg/")
    set_description("Antialiased 2D vector drawing library on top of OpenGL for UI and visualizations.")
    set_license("zlib")

    add_urls("https://github.com/memononen/nanovg.git")

    on_install("windows", "macosx", "linux", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("nanovg")
                set_kind("static")
                add_files("src/*.c")
                add_headerfiles("src/(*.h)")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nvgBeginFrame", {includes = "nanovg.h"}))
    end)
