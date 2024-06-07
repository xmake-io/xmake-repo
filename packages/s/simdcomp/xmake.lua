package("simdcomp")
    set_homepage("https://github.com/lemire/simdcomp")
    set_description("A simple C library for compressing lists of integers using binary packing")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/lemire/simdcomp.git")
    add_versions("2023.08.19", "009c67807670d16f8984c0534aef0e630e5465a4")

    on_install("windows", "linux", "macosx", "bsd", "mingw", "msys", function(package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("simdcomp")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_includedirs("include")
                add_headerfiles("include/*.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function(package)
        assert(package:has_cfuncs("maxbits", {includes = "simdcomputil.h"}))
    end)
