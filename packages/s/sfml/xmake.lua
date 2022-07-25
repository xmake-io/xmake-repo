package("sfml")

    set_homepage("https://www.sfml-dev.org")
    set_description("Simple and Fast Multimedia Library")

    if is_plat("windows", "linux") then
        set_urls("https://www.sfml-dev.org/files/SFML-$(version)-sources.zip")
        add_urls("https://github.com/SFML/SFML/releases/download/$(version)/SFML-$(version)-sources.zip")
        add_versions("2.5.1", "bf1e0643acb92369b24572b703473af60bac82caf5af61e77c063b779471bb7f")
    elseif is_plat("macosx") then
        if is_arch("x64", "x86_64") then
            set_urls("https://www.sfml-dev.org/files/SFML-$(version)-macOS-clang.tar.gz")
            add_versions("2.5.1", "6af0f14fbd41dc038a00d7709f26fb66bb7ccdfe6187657ef0ef8cba578dcf14")
        
            add_configs("debug", {builtin = true, description = "Enable debug symbols.", default = false, type = "boolean", readonly = true})
            add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
        end
    elseif is_plat("mingw") then
        if is_arch("x64", "x86_64") then
            set_urls("https://www.sfml-dev.org/files/SFML-$(version)-windows-gcc-7.3.0-mingw-64-bit.zip")
            add_versions("2.5.1", "671e786f1af934c488cb22c634251c8c8bd441c709b4ef7bc6bbe227b2a28560")
        elseif is_arch("x86", "i386") then
            set_urls("https://www.sfml-dev.org/files/SFML-$(version)-windows-gcc-7.3.0-mingw-32-bit.zip")
            add_versions("2.5.1", "92d864c9c9094dc9d91e0006d66784f25ac900a8ee23c3f79db626de46a1d9d8")
        end
    end

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    add_configs("graphics",   {description = "Use the graphics module", default = true, type = "boolean"})
    add_configs("window",     {description = "Use the window module", default = true, type = "boolean"})
    add_configs("audio",      {description = "Use the audio module", default = true, type = "boolean"})
    add_configs("network",    {description = "Use the network module", default = true, type = "boolean"})
    if is_plat("windows", "mingw") then
        add_configs("main",       {description = "Link to the sfml-main library", default = true, type = "boolean"})
    end

    on_load("windows", "linux", "macosx", "mingw", function (package)
        if package:is_plat("windows", "linux") then
            package:add("deps", "cmake")
        end

        if not package:config("shared") then
            package:add("defines", "SFML_STATIC")
        end

        local e = ""
        local a = "sfml-"
        if not package:config("shared") then
            e = "-s"
        end
        if package:debug() then
            e = e .. "-d"
        end
        local main_module = a .. "main"
        if package:debug() then
            main_module = main_module .. "-d"
        end

        if package:config("graphics") then
            package:add("links", a .. "graphics" .. e)
            if package:is_plat("mingw") then
                package:add("links", "freetype")
            end
        end
        if package:config("window") or package:config("graphics") then
            package:add("links", a .. "window" .. e)
            if package:is_plat("windows", "mingw") then
                package:add("syslinks", "opengl32", "gdi32", "user32", "advapi32")
            end
            if package:is_plat("linux") then
                package:add("deps", "libx11", "libxrandr", "freetype", "eudev")
                package:add("deps", "opengl", "glx", {optional = true})
            end
        end
        if package:config("audio") then
            package:add("links", a .. "audio" .. e)
            if package:is_plat("mingw") then
                package:add("links", "openal32", "flac", "vorbisenc", "vorbisfile", "vorbis", "ogg")
            elseif package:is_plat("linux") then
                package:add("deps", "libogg", "libflac", "libvorbis", "openal-soft")
            end
        end
        if package:config("network") then
            package:add("links", a .. "network" .. e)
            if package:is_plat("windows", "mingw") then
                package:add("syslinks", "ws2_32")
            end
        end
        if package:is_plat("windows", "mingw") and package:config("main") then
            package:add("links", main_module)
        end
        package:add("links", a .. "system" .. e)
        if package:is_plat("windows", "mingw") then
            package:add("syslinks", "winmm")
        end
    end)

    on_install("windows", "linux", function (package)
        local configs = {"-DSFML_BUILD_DOC=OFF", "-DSFML_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=ON")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
            if package:is_plat("windows") and package:config("vs_runtime"):startswith("MT") then
                table.insert(configs, "-DSFML_USE_STATIC_STD_LIBS=ON")
            end
        end
        table.insert(configs, "-DSFML_BUILD_AUDIO=" .. (package:config("audio") and "ON" or "OFF"))
        table.insert(configs, "-DSFML_BUILD_GRAPHICS=" .. (package:config("graphics") and "ON" or "OFF"))
        table.insert(configs, "-DSFML_BUILD_WINDOW=" .. (package:config("window") and "ON" or "OFF"))
        table.insert(configs, "-DSFML_BUILD_NETWORK=" .. (package:config("network") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_install("macosx", "mingw", function (package)
        os.cp("lib", package:installdir())
        os.cp("include", package:installdir())
        if package:is_plat("mingw") then
            os.cp("bin/*", package:installdir("lib"), {rootdir = "bin"})
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                sf::Clock c;
                c.restart();
            }
        ]]}, {includes = "SFML/System.hpp"}))
    end)
