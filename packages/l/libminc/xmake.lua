package("libminc")
    set_homepage("https://github.com/BIC-MNI/libminc")
    set_description("libminc is the core library and API of the MINC toolkit")

    set_urls("https://github.com/BIC-MNI/libminc/archive/refs/tags/release-$(version).tar.gz",
             "https://github.com/BIC-MNI/libminc.git")
    add_versions("2.4.06", "2d8b01e67322507000dbfa3e46fa38e12d5c72eb535b169a33a6c5c53202cf90")

    add_patches("2.4.06", "patches/2.4.06/libminc.patch", "80f00f422f9a59cd6627879c1c51d62a6b1bd379049fe3d86a2663bf7c60b0fb")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake", "hdf5", "zlib")
    if is_plat("linux") then
        add_extsources("apt::libminc-dev")
    end

    on_install("windows", "linux", "macosx", "bsd", function (package)
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DLIBMINC_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DBUILD_TESTING=OFF",
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("miopen_volume", {includes = "minc2.h"}))
    end)