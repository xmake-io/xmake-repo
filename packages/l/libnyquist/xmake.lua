package("libnyquist")
    set_homepage("https://github.com/ddiakopoulos/libnyquist")
    set_description(":microphone: Cross platform C++11 library for decoding audio (mp3, wav, ogg, opus, flac, etc) ")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/ddiakopoulos/libnyquist.git")
    add_versions("2023.02.12", "767efd97cdd7a281d193296586e708490eb6e54f")

    add_deps("cmake")

    on_install(function (package)
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DCMAKE_CXX_STANDARD=14",
            "-DLIBNYQUIST_BUILD_EXAMPLE=Off",
        }
        import("package.tools.cmake").install(package, configs)
        os.cp("include/libnyquist/*.h", package:installdir("include/libnyquist"))
    end)

    on_test(function (package)
        assert(
            package:check_cxxsnippets({
                test = [[
                    #include <libnyquist/Decoders.h>
                    #include <libnyquist/Encoders.h>
                ]]
            }, {
                configs = {
                    languages = "cxx14"
                }
            })
        , "libnyquist: tests failed")
    end)
