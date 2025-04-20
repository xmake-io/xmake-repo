package("tiny-aes-c")
    set_homepage("https://github.com/kokke/tiny-AES-c")
    set_description("Small portable AES128/192/256 in C")
    set_license("Unlicense")

    add_urls("https://github.com/kokke/tiny-AES-c.git")

    add_versions("2021.12.22", "f06ac37fc31dfdaca2e0d9bec83f90d5663c319b")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("tiny-aes-c")
                set_kind("$(kind)")
                add_files("aes.c")
                add_headerfiles("aes.h", "aes.hpp")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("AES_init_ctx", {includes = "aes.h"}))
    end)
