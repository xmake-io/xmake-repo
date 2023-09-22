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

    add_deps("cmake")
    add_deps("glib")
    add_deps("libiconv")
    if not is_plat("linux") then
        add_deps("libintl")
    end
    add_deps("pkgconf")

    on_install("windows", "linux", "macosx", function (package)
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
