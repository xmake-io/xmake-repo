package("libsamplerate")

    set_homepage("http://libsndfile.github.io/libsamplerate/")
    set_description("An audio Sample Rate Conversion library")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/libsndfile/libsamplerate/archive/$(version).tar.gz",
             "https://github.com/libsndfile/libsamplerate.git")

    add_versions("0.2.2", "16e881487f184250deb4fcb60432d7556ab12cb58caea71ef23960aec6c0405a")

    add_deps("cmake")

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", function (package)
        local configs = {}
        table.insert(configs, "-DBUILD_PROGRAMS=OFF")
        table.insert(configs, "-DBUILD_EXAMPLES=OFF")
        table.insert(configs, "-DBUILD_TESTING=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DLIBSAMPLERATE_EXAMPLES=OFF")

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("src_simple", {includes = "samplerate.h"}))
    end)
