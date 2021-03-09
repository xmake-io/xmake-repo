package("lodepng")

    set_homepage("https://lodev.org/lodepng/")
    set_description("PNG encoder and decoder in C and C++.")
    set_license("zlib")

    add_urls("https://github.com/lvandeve/lodepng.git")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("lodepng")
                set_kind("static")
                add_files("lodepng.cpp")
                add_headerfiles("lodepng.h")
        ]])
        import("package.tools.xmake").install(package, {mode = package:debug() and "debug" or "release"})
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("lodepng_decode_memory", {includes = "lodepng.h"}))
    end)
