package("sfml")

    set_homepage("https://www.sfml-dev.org")
    set_description("Simple and Fast Multimedia Library")

    if is_plat("windows") then
        if is_arch("x64") then
            set_urls("https://www.sfml-dev.org/files/SFML-$(version)-windows-vc15-64-bit.zip")
            add_versions("2.5.1", "3e807f7e810d6357ede35acd97615f1fe67b17028ff3d3d946328afb6104ab86")
        elseif is_arch("x86") then
            set_urls("https://www.sfml-dev.org/files/SFML-$(version)-windows-vc15-32-bit.zip")
            add_versions("2.5.1", "9c7bef70ef481884756c9b52851c73caea11eeacb5cc83d03a3c157aee9e395f")
        end
    elseif is_plat("linux") then
        if is_arch("x64", "x86_64") then
            set_urls("https://www.sfml-dev.org/files/SFML-$(version)-linux-gcc-64-bit.tar.gz")
            add_versions("2.5.1", "34ad106e4592d2ec03245db5e8ad8fbf85c256d6ef9e337e8cf5c4345dc583dd")
        end
    elseif is_plat("macosx") then
        if is_arch("x64", "x86_64") then
            set_urls("https://www.sfml-dev.org/files/SFML-$(version)-macOS-clang.tar.gz")
            add_versions("2.5.1", "6af0f14fbd41dc038a00d7709f26fb66bb7ccdfe6187657ef0ef8cba578dcf14")
        end
    elseif is_plat("mingw") then
        if is_arch("x64", "x86_64") then
            set_urls("https://www.sfml-dev.org/files/SFML-$(version)-windows-gcc-7.3.0-mingw-64-bit.zip")
            add_versions("2.5.1", "671e786f1af934c488cb22c634251c8c8bd441c709b4ef7bc6bbe227b2a28560")
        elseif is_arch("x86") then
            set_urls("https://www.sfml-dev.org/files/SFML-$(version)-windows-gcc-7.3.0-mingw-32-bit.zip")
            add_versions("2.5.1", "92d864c9c9094dc9d91e0006d66784f25ac900a8ee23c3f79db626de46a1d9d8")
        end
    end

    add_configs("graphics",   {description = "Use the graphics module", default = true, type = "boolean"})
    add_configs("window",     {description = "Use the window module", default = true, type = "boolean"})
    add_configs("audio",      {description = "Use the audio module", default = true, type = "boolean"})
    add_configs("network",    {description = "Use the network module", default = true, type = "boolean"})
    add_configs("main",       {description = "Link to the sfml-main library", default = true, type = "boolean"})

    on_load("windows", "linux", "macosx", "mingw", function (package)
        if not package:config("shared") then
            package:add("defines", "SFML_STATIC")
            if package:is_plat("windows") then
                package:add("cxflags", "/MD")
            end
        end

        local e = ""
        local a = "sfml-"
        if package:is_plat("windows", "mingw") then
            if not package:config("shared") then
                e = "-s"
            end
            if package:debug() then
                e = e .. "-d"
            end
        end
        local main_module = a .. "main"
        if package:debug() then
            main_module = main_module .. "-d"
        end

        if package:config("graphics") then
            package:add("links", a .. "graphics" .. e)
            if package:is_plat("windows", "mingw") then
                package:add("syslinks", "freetype")
            end
        end
        if package:config("window") or package:config("graphics") then
            package:add("links", a .. "window" .. e)
            if package:is_plat("windows", "mingw") then
                package:add("syslinks", "opengl32", "gdi32", "user32", "advapi32")
            end
        end
        if package:config("audio") then
            package:add("links", a .. "audio" .. e)
            if package:is_plat("windows", "mingw") then
               package:add("syslinks", "openal32", "flac", "vorbisenc", "vorbisfile", "vorbis", "ogg")
            end
        end
        if package:config("network") then
            package:add("links", a .. "network" .. e)
            if package:is_plat("windows", "mingw") then
                package:add("syslinks", "ws2_32")
            end
        end
        package:add("links", a .. "system" .. e)
        if package:is_plat("windows", "mingw") then
            package:add("syslinks", "winmm")
            if package:config("main") then
                package:add("links", main_module)
            end
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        os.cp("lib", package:installdir())
        os.cp("include", package:installdir())
        if package:is_plat("windows", "mingw") then
            os.cp("bin/*", package:installdir("lib"), {rootdir = "bin"})
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                sf::RenderWindow window(sf::VideoMode(200, 200), "SFML works!");
                sf::CircleShape shape(100.f);
                shape.setFillColor(sf::Color::Green);
            }
        ]]}, {includes = "SFML/Graphics.hpp"}))
    end)