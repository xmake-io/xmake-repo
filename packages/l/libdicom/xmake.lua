package("libdicom")
    set_homepage("https://libdicom.readthedocs.io")
    set_description("C library for reading DICOM files")
    set_license("MIT")

    add_urls("https://github.com/ImagingDataCommons/libdicom/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ImagingDataCommons/libdicom.git")

    add_versions("v1.1.0", "a0ab640e050f373bc5a3e1ec99bee7d5b488652340855223a73002181b094ae8")

    add_deps("meson", "ninja")
    if is_plat("windows") then
        add_deps("pkgconf")
    end
    add_deps("uthash")

    on_install("windows|!arm64", "linux", "macosx", "bsd", "mingw", "msys", "iphoneos", "cross", function (package)
        local configs = {"-Dtests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dcm_filehandle_create_from_file", {includes = "dicom/dicom.h"}))
    end)
