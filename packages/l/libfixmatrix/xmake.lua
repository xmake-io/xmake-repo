package("libfixmatrix")
    set_homepage("https://github.com/PetteriAimonen/libfixmatrix")
    set_description("C library for fixed point matrix, quaternion and vector calculations")
    set_license("MIT")

    add_urls("https://github.com/PetteriAimonen/libfixmatrix.git")

    add_versions("2014.01.17", "a8d583e4fe1fa27ba2e0ec55970f73a1b1e6928b")

    add_deps("libfixmath")

    on_install(function (package)
        for _, file in ipairs(os.files("*.h")) do
            io.replace(file, "fix16.h", "libfixmath/fix16.h", {plain = true})
        end

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("libfixmath")
            set_languages("c++11")
            target("fixmatrix")
                set_kind("$(kind)")
                add_files("*.c|*_unittests.c")
                add_headerfiles("*.h|unittests.h", {prefixdir = "libfixmatrix"})
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
                add_packages("libfixmath")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mf16_fill", {includes = "libfixmatrix/fixmatrix.h"}))
    end)
