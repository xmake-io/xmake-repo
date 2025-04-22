package("fluidsynth")

    set_homepage("https://www.fluidsynth.org/")
    set_description("FluidSynth is a real-time software synthesizer based on the SoundFont 2 specifications and has reached widespread distribution.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/FluidSynth/fluidsynth/archive/refs/tags/$(version).zip",
             "https://github.com/FluidSynth/fluidsynth.git")
    add_versions("v2.4.5", "58a29617319afdfbf72b30b8a4afa99724524358cb097ed33e6d1dcdd4989306")
    add_versions("v2.3.3", "0ab6f1aae1c7652b9249de2d98070313f3083046fddd673277556f1cca65568e")
    add_versions("v2.3.5", "3cdaa24777f11fbc6da506d7f7b41fef31822006f83886dcf6e758a9941cae40")

    add_patches("v2.3.3", path.join(os.scriptdir(), "patches", "2.3.3", "find-intl.patch"), "0c80989cce85b8e69409498e3a5d1df41c1ce29bf11261bcb441fdbf08c42f85")
    add_patches("v2.3.5", path.join(os.scriptdir(), "patches", "2.3.5", "find-intl.patch"), "b71c50191e3799e93606b2cf79e61098bdf52d681bd3e758103d2c43c192bfc5")

    add_configs("aufile", {description = "Compile support for sound file output", default = true, type = "boolean"})
    add_configs("dbus", {description = "Compile DBUS support", default = not is_plat("windows"), type = "boolean"})
    add_configs("jack", {description = "Compile JACK support", default = false, type = "boolean"})
    add_configs("libsndfile", {description = "Compile libsndfile support", default = true, type = "boolean"})
    add_configs("opensles", {description = "compile OpenSLES support", default = false, type = "boolean"})
    add_configs("network", {description = "Enable network support (requires BSD or WIN sockets)", default = false, type = "boolean"})
    add_configs("sdl2", {description = "Compile SDL2 audio support ", default = false, type = "boolean"})
    if is_plat("linux") then
        add_configs("pulseaudio", {description = "Compile PulseAudio support", default = false, type = "boolean"})
        add_configs("systemd", {description = "Compile systemd support", default = true, type = "boolean"})
    end
    add_configs("readline", {description = "Compile support for sound file output", default = false, type = "boolean"})
    add_configs("threads", {description = "Enable multi-threading support (such as parallel voice synthesis)", default = true, type = "boolean"})
    add_configs("openmp", {description = "Enable OpenMP support (parallelization of soundfont decoding, vectorization of voice mixing, etc.)", default = false, type = "boolean"})
    if is_plat("macosx") then
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("glib")
    if is_plat("windows") then
        add_deps("libiconv")
        add_deps("pkgconf")
        add_syslinks("ws2_32")
    elseif is_plat("linux") then
        add_deps("libiconv")
        add_deps("pkg-config")
    elseif is_plat("macosx") then
        add_deps("libiconv", {system = true})
        add_deps("libintl")
        add_deps("pkg-config")
    end

    on_load(function (package)
        local configdeps = {
            dbus = "dbus",
            libsndfile = "libsndfile",
            openmp = "openmp",
            readline = "readline",
            sdl2 = "libsdl2"
        }
        for config, info in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", info)
            end
        end
        if package:config("opensles") then
            package:add("links", "OpenSLES")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {}
        local configopts = {
            "aufile", "dbus", "jack", "libsndfile", "opensles", "network", "sdl2", "readline", "pulseaudio", "systemd", "threads", "openmp"
        }
        for _, config in ipairs(configopts) do
            table.insert(configs, "-Denable-" .. config .. "=" .. (package:config(config) and "ON" or "OFF"))
        end
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package)
        if package:is_plat("macosx") then
            local headersdir = package:installdir("Library/Frameworks/FluidSynth.framework/Headers")
            os.cp(path.join(headersdir, "**.h"), package:installdir("include"), {rootdir = headersdir})
            os.cp(path.join(package:installdir("Library/Frameworks/FluidSynth.framework"), "FluidSynth"),
                path.join(package:installdir("lib"), "libFluidSynth.dylib"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                fluid_settings_t* settings = new_fluid_settings();
                fluid_synth_t* synth = new_fluid_synth(settings);
                delete_fluid_synth(synth);
                delete_fluid_settings(settings);
            }
        ]]}, {includes = "fluidsynth.h"}))
    end)
