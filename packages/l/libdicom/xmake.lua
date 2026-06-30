package("libdicom")
    set_homepage("https://libdicom.readthedocs.io")
    set_description("C library for reading DICOM files")
    set_license("MIT")

    add_urls("https://github.com/ImagingDataCommons/libdicom/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ImagingDataCommons/libdicom.git")

    add_versions("v1.3.0", "c753179bc41f4efede3a56f4fab33bc1997bdc9c11036f8b75c4700f20b06524")
    add_versions("v1.2.1", "6e2690497aacc24332761bb7beb91b171ab0434fb753ba09decd7b0b829cc1b6")
    add_versions("v1.2.0", "c44da64a7baceab02ce44c2a5d08f36f192ac6c284f49122328d8588811a38e6")
    add_versions("v1.1.0", "a0ab640e050f373bc5a3e1ec99bee7d5b488652340855223a73002181b094ae8")

    add_deps("meson", "ninja")
    if is_plat("windows") then
        add_deps("pkgconf")
    end
    add_deps("uthash")

    if is_plat("linux", "wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk"):config("ndkver")
            assert(ndk and tonumber(ndk) > 22, "package(libdicom) require ndk version > 22")
        end)
    end

    on_install("windows|!arm64 or !windows", function (package)
        local configs = {"-Dtests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dcm_filehandle_create_from_file", {includes = "dicom/dicom.h"}))
    end)
