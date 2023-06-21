package("sfml")

    set_homepage("https://www.sfml-dev.org")
    set_description("Simple and Fast Multimedia Library")

    -- Before 2.6.0 only x86 is supported for Mac
    if is_plat("macosx") and is_arch("x64", "x86_64") then
        set_urls("https://www.sfml-dev.org/files/SFML-$(version)-macOS-clang.tar.gz")
        add_versions("2.5.1", "6af0f14fbd41dc038a00d7709f26fb66bb7ccdfe6187657ef0ef8cba578dcf14")
    elseif is_plat("windows", "linux", "macosx") then
        set_urls("https://www.sfml-dev.org/files/SFML-$(version)-sources.zip")
        add_urls("https://github.com/SFML/SFML/releases/download/$(version)/SFML-$(version)-sources.zip")
        add_versions("2.5.1", "bf1e0643acb92369b24572b703473af60bac82caf5af61e77c063b779471bb7f")
        add_versions("2.6.0", "dc477fc7266641709046bd38628c909f5748bd2564b388cf6c750a9e20cdfef1")
    elseif is_plat("mingw") then
        set_urls("https://www.sfml-dev.org/files/SFML-$(version)", {version = function (version)
            local arch_str = is_arch("x64", "x86_64") and "64-bit" or "32-bit"

            if version:le("2.5.1") then
                return version .. "-windows-gcc-7.3.0-mingw-" .. arch_str .. ".zip"
            else
                return version .. "-windows-gcc-13.1.0-mingw-" .. arch_str .. ".zip"
            end
        end})

        if is_arch("x64", "x86_64") then
            add_versions("2.5.1", "671e786f1af934c488cb22c634251c8c8bd441c709b4ef7bc6bbe227b2a28560")
            add_versions("2.6.0", "6860f9da5fca995e9e152ee0d63207093513f61d5521a13607704fc25284f790")
        elseif is_arch("x86", "i386") then
            add_versions("2.5.1", "92d864c9c9094dc9d91e0006d66784f25ac900a8ee23c3f79db626de46a1d9d8")
            add_versions("2.6.0", "411d7c0b8a7e351b7c550e4a6d9c45f82cf36dd7550218e7e16a2e1ca6bf407f")
        end
    end

    if is_plat("macosx") then
        add_configs("debug", {builtin = true, description = "Enable debug symbols.", default = false, type = "boolean", readonly = true})
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
        add_extsources("brew::sfml/sfml-all")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("windows", "mingw") then
        add_configs("main", {description = "Link to the sfml-main library", default = true, type = "boolean"})
    end

    add_configs("graphics",   {description = "Use the graphics module", default = true, type = "boolean"})
    add_configs("window",     {description = "Use the window module", default = true, type = "boolean"})
    add_configs("audio",      {description = "Use the audio module", default = true, type = "boolean"})
    add_configs("network",    {description = "Use the network module", default = true, type = "boolean"})

    on_component = on_component or function() end
    on_component("graphics", function (package, component)
        local e = package:config("shared") and "" or "-s"
        if package:debug() then
            e = e .. "-d"
        end
        component:add("links", "sfml-graphics" .. e)
        if package:is_plat("windows", "mingw") and not package:config("shared") then
            component:add("links", "freetype")
            component:add("syslinks", "opengl32", "gdi32", "user32", "advapi32")
        end
        component:add("deps", "window", "system")
        component:add("extsources", "brew::sfml/sfml-graphics")
    end)

    on_component("window", function (package, component)
        local e = package:config("shared") and "" or "-s"
        if package:debug() then
            e = e .. "-d"
        end
        component:add("links", "sfml-window" .. e)
        if package:is_plat("windows", "mingw") and not package:config("shared") then
            component:add("syslinks", "opengl32", "gdi32", "user32", "advapi32")
        end
        component:add("deps", "system")
        component:add("extsources", "brew::sfml/sfml-window")
    end)

    on_component("audio", function (package, component)
        local e = package:config("shared") and "" or "-s"
        if package:debug() then
            e = e .. "-d"
        end
        component:add("links", "sfml-audio" .. e)
        if package:is_plat("windows", "mingw") and not package:config("shared") then
            component:add("links", "openal32", "flac", "vorbisenc", "vorbisfile", "vorbis", "ogg")
        end
        component:add("deps", "system")
        component:add("extsources", "brew::sfml/sfml-audio")
    end)

    on_component("network", function (package, component)
        local e = package:config("shared") and "" or "-s"
        if package:debug() then
            e = e .. "-d"
        end
        component:add("links", "sfml-network" .. e)
        if package:is_plat("windows", "mingw") and not package:config("shared") then
            component:add("syslinks", "ws2_32")
        end
        component:add("deps", "system")
        component:add("extsources", "brew::sfml/sfml-network")
        component:add("extsources", "apt::sfml-network")
    end)

    on_component("system", function (package, component)
        local e = package:config("shared") and "" or "-s"
        if package:debug() then
            e = e .. "-d"
        end
        component:add("links", "sfml-system" .. e)
        if package:is_plat("windows", "mingw") then
            component:add("syslinks", "winmm")
        end
        if package:is_plat("windows", "mingw") and package:config("main") then
            component:add("deps", "main")
        end
        component:add("extsources", "brew::sfml/sfml-system")
    end)

    on_component("main", function (package, component)
        if package:is_plat("windows", "mingw") then
            local main_module = "sfml-main"
            if package:debug() then
                main_module = main_module .. "-d"
            end
            component:add("links", main_module)
        end
    end)

    on_load("windows", "linux", "macosx", "mingw", function (package)
        if package:is_plat("windows", "linux", "macosx") then
            package:add("deps", "cmake")
        end

        if not package:config("shared") then
            package:add("defines", "SFML_STATIC")
        end

        if package:is_plat("linux") then
            if package:config("window") or package:config("graphics") then
                package:add("deps", "libx11", "libxcursor", "libxext", "libxrandr", "libxrender", "freetype", "eudev")
                package:add("deps", "opengl", "glx", {optional = true})
            end
        end

        if package:config("audio") then
            package:add("deps", "libogg", "libflac", "libvorbis", "openal-soft")
        end

        package:add("components", "system")
        for _, component in ipairs({"graphics", "window", "audio", "network"}) do
            if package:config(component) then
                package:add("components", component)
            end
        end

        if package:is_plat("windows", "mingw") and package:config("main") then
            package:add("components", "main")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
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
        local packagedeps
        table.insert(configs, "-DSFML_BUILD_AUDIO=" .. (package:config("audio") and "ON" or "OFF"))
        table.insert(configs, "-DSFML_BUILD_GRAPHICS=" .. (package:config("graphics") and "ON" or "OFF"))
        table.insert(configs, "-DSFML_BUILD_WINDOW=" .. (package:config("window") and "ON" or "OFF"))
        table.insert(configs, "-DSFML_BUILD_NETWORK=" .. (package:config("network") and "ON" or "OFF"))

        -- SFML doesn't provide prebuilt ARM binaries for the dependencies on Windows
        if package:is_plat("windows") and not package:is_arch("x64", "x86_64", "x86", "i386") then
            table.insert(configs, "-DSFML_USE_SYSTEM_DEPS=TRUE")
        end

        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)

    on_install("mingw", function (package)
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
        if package:config("graphics") then
            assert(package:check_cxxsnippets({test = [[
                void test(int args, char** argv) {
                    sf::Text text;
                    text.setString("Hello world");
                }
            ]]}, {includes = "SFML/Graphics.hpp"}))
        end
        if package:config("window") or package:config("graphics") then
            assert(package:check_cxxsnippets({test = [[
                void test(int args, char** argv) {
                    sf::Window window(sf::VideoMode(1280, 720), "Title");

                    sf::Event event;
                    window.pollEvent(event);
                }
            ]]}, {includes = "SFML/Window.hpp"}))
        end
        if package:config("audio") then
            assert(package:check_cxxsnippets({test = [[
                void test(int args, char** argv) {
                    sf::Music music;
                    music.openFromFile("music.ogg");
                    music.play();
                }
            ]]}, {includes = "SFML/Audio.hpp"}))
        end
        if package:config("network") then
            assert(package:check_cxxsnippets({test = [[
                void test(int args, char** argv) {
                    sf::UdpSocket socket;
                    socket.bind(54000);

                    char data[100];
                    std::size_t received;
                    sf::IpAddress sender;
                    unsigned short port;
                    socket.receive(data, 100, received, sender, port);
                }
            ]]}, {includes = "SFML/Network.hpp"}))
        end
    end)
package_end()

