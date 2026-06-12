package("rubberband")
    set_homepage("https://breakfastquay.com/rubberband/")
    set_description("A high quality software library for audio time-stretching and pitch-shifting.")
    set_license("GPL-2.0-or-later OR Commercial Licenses")
    -- For commercial licenses, see https://breakfastquay.com/technology/license.html, next to "Rubber Band Library".
    -- From README: "If you wish to distribute code using Rubber Band Library under terms other than those of
    -- the GNU General Public License, you must obtain a commercial licence from us before doing so. In
    -- particular, you may not legally distribute through any Apple App Store unless you have a commercial licence."

    add_urls("https://github.com/breakfastquay/rubberband/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/breakfastquay/rubberband.git")

    add_versions("4.0.0", "24300f48a8014b7c863b573a9647e61b1b19b37875e2cdd92005e64c6424d266")

    add_configs("fft", {description = "FFT library to use. The default (auto) will use vDSP if available, the builtin implementation otherwise.", default = "auto", type = "string",
                        values = {"auto", "builtin", "kissfft", "fftw", "vdsp", "ipp"}}) --TODO: Add sleef once it's available on xrepo.

    add_configs("resampler", {description = "Resampler library to use. The default (auto) simply uses the builtin implementation.", default = "auto", type = "string",
                              values = {"auto", "builtin", "libsamplerate", "speex", "libspeexdsp", "ipp"}})

    add_configs("ipp_path", {description = "Path to Intel IPP libraries, if selected for any of the other options.", default = "", type = "string"})

    add_configs("jni", {description = "Build JNI bindings", default = false, type = "boolean"})
    add_configs("lv2", {description = "Build LV2 plugin", default = false, type = "boolean"})
    add_configs("vamp", {description = "Build Vamp plugin", default = false, type = "boolean"})
    add_configs("cmdline", {description = "Build command-line utility", default = false, type = "boolean"})

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    -- To pass on_test
    if is_plat("bsd") then
        add_syslinks("pthread")
    end

    add_deps("meson", "ninja")        

    on_load(function (package)
        -- FFT: KissFFT is vendored in. vDSP is Apple specific.
        if package:config("fft") == "fftw" then
            package:add("deps", "fftw")
        end

        --Resampler: Speex is vendored in.
        if package:config("resampler") == "libsamplerate" then
            package:add("deps", "libsamplerate")
        end

        -- Plugin SDKs
        if package:config("lv2") then
            package:add("deps", "lv2")
        end
        if package:config("vamp") then
            package:add("deps", "vamp-plugin-sdk")
        end

        if package:config("cmdline") then
            package:add("deps", "libsndfile")
        end

        -- vDSP (and the auto default on macOS) requires the Accelerate framework
        if package:is_plat("macosx", "iphoneos") and (package:config("fft") == "auto" or package:config("fft") == "vdsp") then
            package:add("frameworks", "Accelerate")
        end
    end)

    on_install("!android", function (package)
        local configs = {
            "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"),
            "-Dfft=" .. package:config("fft"),
            "-Dresampler=" .. package:config("resampler"),
            "-Dipp_path=" .. package:config("ipp_path"),
            "-Djni=" .. (package:config("jni") and "enabled" or "disabled"),
            "-Dlv2=" .. (package:config("lv2") and "enabled" or "disabled"),
            "-Dvamp=" .. (package:config("vamp") and "enabled" or "disabled"),
            "-Dcmdline=" .. (package:config("cmdline") and "enabled" or "disabled"),
            "-Dtests=disabled"
        }

        -- iPhoneOS fix error relating to libatomic
        if package:is_plat("iphoneos") then
            io.replace("meson.build",
                "if cpp.compiles(libatomic_test_program, name : 'test program using std::atomic')",
                "if system != 'darwin' and system != 'ios' and cpp.compiles(libatomic_test_program, name : 'test program using std::atomic')",
                {plain = true})
        end
        -- wasm fix errors relating to size_t
        if package:is_plat("wasm") then
            io.replace("src/common/mathmisc.h",
                '#include "sysutils.h"',
                '#include "sysutils.h"\n#include <cstddef>',
        {plain = true})
        end
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("rubberband_new", {includes = "rubberband/rubberband-c.h"}))
    end)
