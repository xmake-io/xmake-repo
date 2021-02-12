package("libsoundio")
    set_homepage("http://libsound.io/")
    set_description("C library for cross-platform real-time audio input and output.")
    set_license("MIT")

    set_urls("https://github.com/andrewrk/libsoundio/archive/$(version).tar.gz",
             "https://github.com/andrewrk/libsoundio.git")

    add_versions("2.0.0", "67a8fc1c9bef2b3704381bfb3fb3ce99e3952bc4fea2817729a7180fddf4a71e")
    add_patches("2.0.0", path.join(os.scriptdir(), "patches", "2.0.0", "extern.patch"), "c1c9084012cf39b203cdf7c59d46a8e6362b6a1e7203700d77faef529d49d401")

    add_includedirs("include", "include/soundio")

    if is_plat("windows") then
        add_syslinks("ole32")
    end

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "SOUNDIO_STATIC_LIBRARY")
        end
    end)

    on_install(function (package)
        io.gsub("src/config.h.in", "#cmakedefine SOUNDIO_HAVE_JACK", "${define SOUNDIO_HAVE_JACK}")
        io.gsub("src/config.h.in", "#cmakedefine SOUNDIO_HAVE_PULSEAUDIO", "${define SOUNDIO_HAVE_PULSEAUDIO}")
        io.gsub("src/config.h.in", "#cmakedefine SOUNDIO_HAVE_ALSA", "${define SOUNDIO_HAVE_ALSA}")
        io.gsub("src/config.h.in", "#cmakedefine SOUNDIO_HAVE_COREAUDIO", "${define SOUNDIO_HAVE_COREAUDIO}")
        io.gsub("src/config.h.in", "#cmakedefine SOUNDIO_HAVE_WASAPI", "${define SOUNDIO_HAVE_WASAPI}")
        io.gsub("src/config.h.in", "@LIBSOUNDIO_VERSION_MAJOR@", "${VERSION_MAJOR}")
        io.gsub("src/config.h.in", "@LIBSOUNDIO_VERSION_MINOR@", "${VERSION_MINOR}")
        io.gsub("src/config.h.in", "@LIBSOUNDIO_VERSION_PATCH@", "${VERSION_ALTER}")
        io.gsub("src/config.h.in", "@LIBSOUNDIO_VERSION@",  package:version_str())
        io.writefile("xmake.lua", ([[
            set_version("%s")
            add_rules("mode.debug", "mode.release")
            target("soundio")
                set_kind("$(kind)")
                add_files("src/*.c|alsa.c|jack.c|wasapi.c|pulseaudio.c|coreaudio.c")
                add_includedirs(".", "soundio")
                set_configdir("soundio")
                add_configfiles("src/config.h.in")
                add_headerfiles("(soundio/*.h)")
                if is_plat("windows") then
                    add_cflags("/TP") -- fix missing stdatomic.h
                    add_syslinks("ole32")
                end
        ]]):format(package:version_str()))
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        elseif not package:is_plat("windows", "mingw") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("soundio_create", {includes = "soundio/soundio.h"}))
    end)
