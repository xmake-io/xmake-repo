package("sha2")
    set_homepage("https://github.com/ogay/sha2")
    set_description("Fast software implementation in C of the FIPS 180-2 hash algorithms SHA-224, SHA-256, SHA-384 and SHA-512.")

    add_urls("https://github.com/ogay/sha2.git")

    add_versions("2024.05.23", "b90991f90967a46d0955dc981e9e3cd53c13b061")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_rules("utils.install.pkgconfig_importfiles", {filename = "libsha2.pc"})
            target("sha2")
                set_kind("$(kind)")
                if is_plat("windows") and is_kind("shared") then 
                    add_rules("utils.symbols.export_all") 
                end 
                add_files("sha2.c")
                add_headerfiles("sha2.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sha256_update", {includes = "sha2.h"}))
    end)
