package("libfixmath")
    set_homepage("https://github.com/PetteriAimonen/libfixmath")
    set_description("Cross Platform Fixed Point Maths Library")
    set_license("MIT")

    add_urls("https://github.com/PetteriAimonen/libfixmath.git")

    add_versions("2026.07.14", "ed9391c33a56078c126e3e7a811a883c8c87daa2")
    add_versions("2023.08.06", "d308e466e1a09118d03f677c52e5fbf402f6fdd0")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++11")
            target("fixmath")
                set_kind("$(kind)")
                add_files("libfixmath/*.c")
                add_headerfiles("(libfixmath/*.h)", "(libfixmath/*.hpp)")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("uint32_log2", {includes = "libfixmath/uint32.h"}))
    end)
