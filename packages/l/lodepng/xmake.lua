package("lodepng")
    set_homepage("https://lodev.org/lodepng/")
    set_description("PNG encoder and decoder in C and C++.")
    set_license("zlib")

    add_urls("https://github.com/lvandeve/lodepng.git")

    add_versions("2025.05.06", "17d08dd26cac4d63f43af217ebd70318bfb8189c")

    add_patches("2025.05.06", "https://patch-diff.githubusercontent.com/raw/lvandeve/lodepng/pull/182.diff", "ec7f2ab3f2515cef3e422a41d8fcc215295ba1d0d761f52f54f199a6aa584ba3")

    add_configs("cpp", {description = "Enable C++ support.", default = true, type = "boolean"})

    on_install(function (package)
        local src = "lodepng.cpp"
        if not package:config("cpp") then
            src = "lodepng.c"
            os.mv("lodepng.cpp", "lodepng.c")
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("lodepng")
                set_kind("$(kind)")
                add_files("]] .. src .. [[")
                add_headerfiles("lodepng.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("lodepng_decode_memory", {includes = "lodepng.h"}))
    end)
