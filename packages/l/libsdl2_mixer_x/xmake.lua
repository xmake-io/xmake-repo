package("libsdl2_mixer_x")
    set_homepage("https://wohlsoft.github.io/SDL-Mixer-X/")
    set_description('SDL Mixer X (Or "MixerX" shortly) - An audio mixer library based on the SDL library, a fork of SDL_mixer')

    add_urls("https://github.com/WohlSoft/SDL-Mixer-X/archive/refs/tags/$(version).tar.gz",
             "https://github.com/WohlSoft/SDL-Mixer-X.git")

    add_versions("2.7.0", "28d1fd54e616cc285839936cc209d874504a2725")
    add_versions("2.6.0", "9e97247483ef7102442dcb836309b204ccefed503d1bc38996093c79ab284b1e")

    add_configs("lgpl", {description = "Use libflac to playEnable components with LGPL license", default = false, type = "boolean"})
    add_configs("gpl", {description = "Enable using of components with GPL and LGPL licenses", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("libsdl2")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMIXERX_ENABLE_LGPL=" .. (package:config("lgpl") and "ON" or "OFF"))
        table.insert(configs, "-DMIXERX_ENABLE_GPL=" .. (package:config("gpl") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <SDL2/SDL.h>
            #include <SDL2/SDL_mixer_ext.h>
            int main(int argc, char** argv) {
                Mix_Init(MIX_INIT_OGG);
                Mix_Quit();
                return 0;
            }
        ]]}, {configs = {defines = "SDL_MAIN_HANDLED"}}));
    end)
