package("cgif")
    set_homepage("https://github.com/dloebl/cgif")
    set_description("GIF encoder written in C")
    set_license("MIT")

    add_urls("https://github.com/dloebl/cgif/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dloebl/cgif.git")

    add_versions("v0.4.0", "130ff8a604f047449e81ddddf818bd0e03826b5f468e989b02726b16b7d4742e")

    if is_plat("linux") then
        add_extsources("apt::libcgif-dev", "pacman::libcgif")
    elseif is_plat("macosx") then
        add_extsources("brew::cgif")
    end

    add_deps("meson", "ninja")

    on_install(function (package)
        local configs = {"-Dexamples=false", "-Dtests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cgif_newgif", {includes = "cgif.h"}))
    end)
