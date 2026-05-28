package("rubberband")
    set_homepage("https://breakfastquay.com/rubberband/")
    set_description("A high quality software library for audio time-stretching and pitch-shifting.")
    set_license("GPL-2.0-or-later")

    add_urls("https://github.com/breakfastquay/rubberband/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/breakfastquay/rubberband.git")

    add_versions("4.0.0", "24300f48a8014b7c863b573a9647e61b1b19b37875e2cdd92005e64c6424d266")

    add_configs("fft", {description = "FFT library to use. The default (auto) will use vDSP if available, the builtin implementation otherwise.", default = "auto", type = "string",
                        values = {"auto", "builtin", "kissfft", "fftw", "vdsp", "ipp"}}) --TODO: Add sleef once it's available on xrepo.

    add_configs("resampler", {description = "Resampler library to use. The default (auto) simply uses the builtin implementation.", default = "auto", type = "string",
                              values = {"auto", "builtin", "libsamplerate", "speex", "libspeexdsp", "ipp"}})

    add_configs("ipp_path", {description = "Path to Intel IPP libraries, if selected for any of the other options.", default = "", type = "string"})

    add_configs("jni", {description = "Build JNI bindings", default = "disabled", type = "string",
                        values = {"auto", "enabled", "disabled"}})  -- Is adding JDK as a dependency needed for this option?

    --add_configs("ladspa", {description = "Build LADSPA plugin", default = "disabled", type = "string",
                           --values = {"auto", "enabled", "disabled"}})
    -- Not sure if ladspa-sdk can even be added to xrepo.

    add_configs("lv2", {description = "Build LV2 plugin", default = "disabled", type = "string",
                        values = {"auto", "enabled", "disabled"}})

    add_configs("vamp", {description = "Build Vamp plugin", default = "disabled", type = "string",
                         values = {"auto", "enabled", "disabled"}})

    add_configs("cmdline", {description = "Build command-line utility", default = "disabled", type = "string",
                            values = {"auto", "enabled", "disabled"}})

    add_deps("meson", "ninja")        

    on_load(function (package)
        -- FFT: KissFFT is vendored in. vDSP is Apple specific.
        if package:config("fft") == "fftw" then
            package:add("deps", "fftw")
        --elseif package:config("fft") == "sleef" then
            --package:add("deps", "sleef")
        end

        --Resampler: Speex is vendored in.
        if package:config("resampler") == "libsamplerate" then
            package:add("deps", "libsamplerate")
        end

        -- Plugin SDKs
        --if package:config("ladspa") == "enabled" then
        --    package:add("deps", "ladspa-sdk")
        --end
        if package:config("lv2") == "enabled" then
            package:add("deps", "lv2")
        end
        if package:config("vamp") == "enabled" then
            package:add("deps", "vamp-plugin-sdk")
        end

        if package:config("cmdline") == "enabled" then
            package:add("deps", "libsndfile")
        end
    end)

    on_install(function (package)
        local configs = {
            "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"),
            "-Dfft=" .. package:config("fft"),
            "-Dresampler=" .. package:config("resampler"),
            "-Dipp_path=" .. package:config("ipp_path"),
            "-Djni=" .. package:config("jni"),
            --"-Dladspa=" .. package:config("ladspa"),
            "-Dlv2=" .. package:config("lv2"),
            "-Dvamp=" .. package:config("vamp"),
            "-Dcmdline=" .. package:config("cmdline"),
            "-Dtests=disabled"
        }

        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("rubberband_new", {includes = "rubberband/rubberband-c.h"}))
    end)
