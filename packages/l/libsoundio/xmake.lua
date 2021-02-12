package("libsoundio")
    set_homepage("http://libsound.io/")
    set_description("C library for cross-platform real-time audio input and output.")
    set_license("MIT")

    set_urls("https://github.com/andrewrk/libsoundio/archive/$(version).tar.gz",
             "https://github.com/andrewrk/libsoundio.git")

    add_versions("2.0.0", "67a8fc1c9bef2b3704381bfb3fb3ce99e3952bc4fea2817729a7180fddf4a71e")

    add_includedirs("include", "include/soundio")

    add_configs("jack",       { description = "Enable JACK backend.", default = false, type = "boolean"})
    add_configs("pulseaudio", { description = "Enable PulseAudio backend.", default = false, type = "boolean"})
    add_configs("alsa",       { description = "Enable Alsa backend.", default = false, type = "boolean"})
    add_configs("coreaudio",  { description = "Enable CoreAudio backend.", default = false, type = "boolean"})
    add_configs("wasapi",     { description = "Enable WASAPI backend.", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("ole32")
    elseif is_plat("linux", "bsd", "macosx") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:is_plat("windows", "mingw") and not package:config("shared") then
            package:add("defines", "SOUNDIO_STATIC_LIBRARY")
        elseif package:is_plat("macosx") and package:config("coreaudio") and not package:config("shared") then
            package:add("frameworks", "CoreAudio", "CoreFoundation", "AudioToolbox")
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
            for _, name in ipairs({"jack", "pulseaudio", "alsa", "coreaudio", "wasapi"}) do
                option(name)
                    set_default(false)
                    set_showmenu(true)
                    set_configvar("SOUNDIO_HAVE_" .. name:upper(), 1)
                    if name == "coreaudio" then
                        add_frameworks("CoreAudio", "CoreFoundation", "AudioToolbox")
                    else
                        -- TODO for other backend or use add_requires
                    end
                option_end()
            end
            target("soundio")
                set_kind("$(kind)")
                add_files("src/*.c|alsa.c|jack.c|wasapi.c|pulseaudio.c|coreaudio.c")
                add_includedirs(".", "soundio")
                set_configdir("soundio")
                add_configfiles("src/config.h.in")
                add_headerfiles("(soundio/*.h)")
                if is_plat("windows") then
                    add_cflags("/TP") -- fix missing stdatomic.h
                end
                for _, name in ipairs({"jack", "pulseaudio", "alsa", "coreaudio", "wasapi"}) do
                    if has_config(name) then
                        add_files("src/" .. name .. ".c")
                        add_options(name)
                    end
                end
                if is_kind("shared") then
                    if is_plat("windows", "mingw") then
                        add_syslinks("ole32")
                    elseif is_plat("linux", "bsd", "macosx") then
                        add_syslinks("pthread")
                    end
                end
        ]]):format(package:version_str()))
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        elseif not package:is_plat("windows", "mingw") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        -- TODO we only support coreaudio backend now
        for _, name in ipairs({"jack", "pulseaudio", "alsa", "coreaudio", "wasapi"}) do
            if package:config(name) then
                configs[name] = true
            end
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("soundio_create", {includes = "soundio/soundio.h"}))
    end)
