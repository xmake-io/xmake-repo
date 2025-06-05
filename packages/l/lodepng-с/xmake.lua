package("lodepng-с")
    set_homepage("https://lodev.org/lodepng/")
    set_description("PNG encoder and decoder in C and C++.")
    set_license("zlib")

    add_urls("https://github.com/lvandeve/lodepng.git")
    add_versions("2025.05.06", "17d08dd26cac4d63f43af217ebd70318bfb8189c")

    on_install(function (package)
        os.mv("lodepng.cpp", "lodepng.c")
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("lodepng")
                set_kind("$(kind)")
                add_files("lodepng.c")
                add_headerfiles("lodepng.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lodepng_decode_memory", {includes = "lodepng.h"}))
    end)
