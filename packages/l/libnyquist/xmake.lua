package("libnyquist")
    set_homepage("https://github.com/ddiakopoulos/libnyquist")
    set_description(":microphone: Cross platform C++11 library for decoding audio (mp3, wav, ogg, opus, flac, etc) ")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/ddiakopoulos/libnyquist.git")
    add_versions("2023.02.12", "767efd97cdd7a281d193296586e708490eb6e54f")

    add_patches("2023.02.12", path.join(os.scriptdir(), "patches", "-Wno-register.patch"),
        "c2963c0a1bb8b9fed57bc629022b2965ad00c8b4e800d490f659036203d20d5f")

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
            package:has_cxxincludes("libnyquist/Encoders.h") and
            package:has_cxxfuncs("nqr::BaseDecoder::LoadFromPath", { includes = "libnyquist/Decoders.h" }) and
            package:has_cxxfuncs("nqr::BaseDecoder::LoadFromBuffer", { includes = "libnyquist/Decoders.h" }) and
            package:has_cxxfuncs("nqr::BaseDecoder::GetSupportedFileExtensions", { includes = "libnyquist/Decoders.h" }) and
            package:has_cxxfuncs("nqr::encode_wav_to_disk", { includes = "libnyquist/Encoders.h" }) and
            package:has_cxxfuncs("nqr::encode_opus_to_disk", { includes = "libnyquist/Encoders.h" })
        , "libnyquist: tests failed")
    end)
