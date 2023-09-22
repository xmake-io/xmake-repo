package("fluidsynth")

    set_homepage("https://www.fluidsynth.org/")
    set_description("FluidSynth is a real-time software synthesizer based on the SoundFont 2 specifications and has reached widespread distribution.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/FluidSynth/fluidsynth/archive/refs/tags/$(version).zip",
             "https://github.com/FluidSynth/fluidsynth.git")
    add_versions("v2.3.3", "0ab6f1aae1c7652b9249de2d98070313f3083046fddd673277556f1cca65568e")
    if not is_plat("linux") then
        add_patches("v2.3.3", path.join(os.scriptdir(), "patches", "find-intl.patch"), "d6a8f4f162845b47b9cd772863b196775577f90fe5421f9de2ec72becbb087f3")
    end

    -- Some libraries are required for build with our default config settings.
    local configfeats = {
        ["enable-aufile"] = {
            lib = nil,
            desc = "Compile support for sound file output",
            default = true
        },
        ["enable-libsndfile"] = {
            lib = "libsndfile",
            desc = "Compile libsndfile support",
            default = true
        },
        ["enable-dbus"] = {
            lib = "dbus",
            desc = "Compile DBUS support ",
            default = not is_plat("windows")
        },
        ["enable-sdl2"] = {
            lib = "libsdl",
            desc = "Compile SDL2 audio support ",
            default = false
        },
        ["enable-readline"] = {
            lib = "readline",
            desc = "Compile readline lib line editing ",
            default = false
        },
        ["enable-threads"] = {
            lib = nil,
            desc = "enable multi-threading support (such as parallel voice synthesis)",
            default = true
        },
        ["enable-openmp"] = {
            lib = "openmp",
            desc = "enable OpenMP support (parallelization of soundfont decoding, vectorization of voice mixing, etc.)",
            default = false
        },
    }
    for config, info in pairs(configdeps) do
        add_configs(config, {description = info.desc, default = info.default, type = "boolean"})
    end

    add_deps("cmake")
    add_deps("glib")
    add_deps("libiconv")
    if is_plat("windows") then
        add_deps("libintl")
        add_deps("pkgconf")
        add_syslinks("ws2_32")
    elseif is_plat("linux") then
        add_deps("pkg-config")
    else
        add_deps("libintl")
        add_deps("pkg-config")
    end

    on_load(function (package)
        for config, info in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", info.lib)
            end
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {}
        for config, info in pairs(configdeps) do
            table.insert(configs, "-D" .. config .. "=" .. (package:config(config) and "ON" or "OFF"))
        end
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() 
            {
                fluid_settings_t* settings = new_fluid_settings();
                fluid_synth_t* synth = new_fluid_synth(settings);
                delete_fluid_synth(synth);
                delete_fluid_settings(settings);
            }
        ]]}, {includes = "fluidsynth.h"}))
    end)
