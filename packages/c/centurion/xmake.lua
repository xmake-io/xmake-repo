package("centurion")
    set_kind("library", { headeronly = true })
    set_homepage("https://github.com/albin-johansson/centurion")
    set_description("A modern C++ wrapper library for SDL2 in order to improve type-safety, memory safety and overall ease-of-use.")
    set_license("MIT")

    set_urls("https://github.com/albin-johansson/centurion/archive/refs/tags/$(version).tar.gz",
             "https://github.com/albin-johansson/centurion.git")

    add_versions("v7.3.0", "ad8b7c27074939fa46380a878e82c2b0365d1c4ad31b4a71bfcd5ce3ac0198e6")

    add_patches("v7.3.0", path.join(os.scriptdir(), "patches", "7.3.0", "fix_method_name.patch"), "2c5faf24867440e53bdabf79b4354cdbf2c79707ca9e372ba7cdd94bcb1dcc52")

    add_configs("pragma_once", { description = "Use #pragma once in centurion.hpp", default = true, type = "boolean" })
    add_configs("debug_macros", { description = "Include debug-only logging macros, such as CENTURION_LOG_INFO", default = true, type = "boolean" })

    add_configs("sdl_image", { description = "Enable library components that rely on the SDL_image library", default = true, type = "boolean" })
    add_configs("sdl_mixer", { description = "Enable library components that rely on the SDL_mixer library", default = true, type = "boolean" })
    add_configs("sdl_ttf", { description = "Enable library components that rely on the SDL_ttf library", default = true, type = "boolean" })

    add_configs("vulkan", { description = "Enable library components related to Vulkan", default = true, type = "boolean" })
    add_configs("opengl", { description = "Enable library components related to OpenGL", default = true, type = "boolean" })

    if is_plat("wasm") then
        add_configs("shared", { description = "Build shared library.", default = false, type = "boolean", readonly = true })
    end

    add_includedirs("include", "include/SDL2")

    on_load(function (package)
        package:add("deps", "libsdl2", { configs = { shared = package:config("shared") } })

        if not package:config("pragma_once") then
            package:add("defines", "CENTURION_NO_PRAGMA_ONCE")
        end
        if not package:config("debug_macros") then
            package:add("defines", "CENTURION_NO_DEBUG_LOG_MACROS")
        end

        if package:config("sdl_image") then
            package:add("deps", "libsdl2_image", { configs = { shared = package:config("shared") } })
        else
            package:add("defines", "CENTURION_NO_SDL_IMAGE")
        end
        if package:config("sdl_mixer") then
            package:add("deps", "libsdl2_mixer", { configs = { shared = package:config("shared") } })
        else
            package:add("defines", "CENTURION_NO_SDL_MIXER")
        end
        if package:config("sdl_ttf") then
            package:add("deps", "libsdl2_ttf", { configs = { shared = package:config("shared") } })
        else
            package:add("defines", "CENTURION_NO_SDL_TTF")
        end

        if not package:config("vulkan") then
            package:add("defines", "CENTURION_NO_VULKAN")
        end
        if not package:config("opengl") then
            package:add("defines", "CENTURION_NO_OPENGL")
        end
    end)

    on_install(function (package)
        os.cp("src/*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({ test = [[
            int main() {
                const cen::sdl sdl;
                cen::window window { "Centurion" };
                cen::renderer renderer = window.make_renderer();
                window.show();
                window.hide();
            }
        ]] }, { configs = { languages = "c++17", defines = "SDL_MAIN_HANDLED" }, includes = "centurion.hpp" }))
        if package:config("sdl_image") then
            assert(package:check_cxxsnippets({ test = [[
                int main() {
                    const cen::img img;
                }
            ]] }, { configs = { languages = "c++17", defines = "SDL_MAIN_HANDLED" }, includes = "centurion.hpp" }))
        end
        if package:config("sdl_mixer") then
            assert(package:check_cxxsnippets({ test = [[
                int main() {
                    const cen::mix mix;
                }
            ]] }, { configs = { languages = "c++17", defines = "SDL_MAIN_HANDLED" }, includes = "centurion.hpp" }))
        end
        if package:config("sdl_ttf") then
            assert(package:check_cxxsnippets({ test = [[
                int main() {
                    const cen::ttf ttf;
                }
            ]] }, { configs = { languages = "c++17", defines = "SDL_MAIN_HANDLED" }, includes = "centurion.hpp" }))
        end
    end)
