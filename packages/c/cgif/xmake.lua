package("cgif")
    set_homepage("https://github.com/dloebl/cgif")
    set_description("GIF encoder written in C")
    set_license("MIT")

    add_urls("https://github.com/dloebl/cgif/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dloebl/cgif.git")

    add_versions("v0.5.1", "211e3dfba7138e4cbc1272999aa735be52fc14cab8cb000d9d6aa9d294423034")
    add_versions("v0.5.0", "d6cb312c7da2c6c9f310811aa3658120c0316ba130c48a012e7baf3698920fe9")
    add_versions("v0.4.1", "8666f9c5f8123d1c22137a6dd714502a330377fb74e2007621926fe4258529d5")
    add_versions("v0.4.0", "130ff8a604f047449e81ddddf818bd0e03826b5f468e989b02726b16b7d4742e")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("linux") then
        add_extsources("apt::libcgif-dev", "pacman::libcgif")
    elseif is_plat("macosx") then
        add_extsources("brew::cgif")
    end

    add_deps("meson", "ninja")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk"):config("ndkver")
            assert(ndk and tonumber(ndk) > 22, "package(cgif) require ndk version > 22")
        end)
    end

    on_install(function (package)
        local opt = {}
        if package:is_plat("windows") and package:config("shared") then
            io.replace("inc/cgif.h", "CGIF* cgif_newgif", "LIBRARY_API CGIF* cgif_newgif", {plain = true})
            io.replace("inc/cgif.h", "int   cgif_addframe", "LIBRARY_API int cgif_addframe", {plain = true})
            io.replace("inc/cgif.h", "int   cgif_close", "LIBRARY_API int cgif_close", {plain = true})
            opt.cxflags = "-DLIBRARY_API=__declspec(dllexport)"
            package:add("defines", "LIBRARY_API=__declspec(dllimport)")
        end

        local configs = {"-Dexamples=false", "-Dtests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cgif_newgif", {includes = "cgif.h"}))
    end)
