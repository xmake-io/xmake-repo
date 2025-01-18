package("libnyquist")
    set_homepage("https://github.com/ddiakopoulos/libnyquist")
    set_description(":microphone: Cross platform C++11 library for decoding audio (mp3, wav, ogg, opus, flac, etc) ")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/ddiakopoulos/libnyquist.git")
    add_versions("2023.02.12", "767efd97cdd7a281d193296586e708490eb6e54f")

    add_deps("cmake")

    on_install(function (package)
        local is_byte_order_little = package:check_csnippets({
            test = [[
                #if !(defined(__BYTE_ORDER__) && __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__)
                #error not little endian
                #endif
            ]]
        }, {})
        local is_msvc = package:check_csnippets({
            test = [[
                #if !(defined(_MSC_VER) && !defined(__clang__) && !defined(__INTEL_COMPILER))
                #error not msvc
                #endif
            ]]
        })

        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DCMAKE_CXX_STANDARD=14",
            "-DCMAKE_CXX_FLAGS=\z
                -D" .. (
                    (package:is_targetarch("x86_64", "i%d86") or is_byte_order_little)
                    and "ARCH_CPU_LITTLE_ENDIAN"
                    or "ARCH_CPU_BIG_ENDIAN"
                ) .. (
                    (not is_msvc) and " -Wno-implicit-function-declaration" or ""
                ),
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
