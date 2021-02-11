package("libsoundio")
    set_homepage("http://libsound.io/")
    set_description("C library for cross-platform real-time audio input and output.")
    set_license("MIT")

    set_urls("https://github.com/andrewrk/libsoundio/archive/$(version).tar.gz",
             "https://github.com/andrewrk/libsoundio.git")

    add_versions("2.0.0", "67a8fc1c9bef2b3704381bfb3fb3ce99e3952bc4fea2817729a7180fddf4a71e")
    add_patches("2.0.0", path.join(os.scriptdir(), "patches", "2.0.0", "extern.patch"), "c1c9084012cf39b203cdf7c59d46a8e6362b6a1e7203700d77faef529d49d401")

    add_deps("cmake")

    add_includedirs("include", "include/soundio")

    on_install("windows", "linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if is_plat("windows") then
            -- compile as C++ because C11 is not widely supported with MSVC
            import("package.tools.cmake").install(package, configs, {cxflags = {"/TP", "/std:c++11"}})
        else
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("soundio_create", {includes = "soundio/soundio.h"}))
    end)
