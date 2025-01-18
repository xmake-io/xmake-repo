package("libnyquist")
    set_homepage("https://github.com/ddiakopoulos/libnyquist")
    set_description(":microphone: Cross platform C++11 library for decoding audio (mp3, wav, ogg, opus, flac, etc) ")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/ddiakopoulos/libnyquist.git")
    add_versions("2023.02.12", "767efd97cdd7a281d193296586e708490eb6e54f")

    add_patches("2023.02.12", path.join(os.scriptdir(), "patches", "error-deprecated-register.patch"),
        "1bbf8462e8d3fac5d9b533e59ee475165650c5f7d9439b46da9b6f5cf25dd40f")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
        os.cp("include/libnyquist/*.h", package:installdir("include/libnyquist"))
    end)

    on_test(function (package)
        assert(
            package:has_cxxincludes("libnyquist/Decoders.h") and
            package:has_cxxincludes("libnyquist/Encoders.h")
        , "libnyquist: tests failed")
    end)
