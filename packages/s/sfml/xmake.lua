package("sfml")
    set_homepage("https://www.sfml-dev.org")
    set_description("Simple and Fast Multimedia Library")
    set_license("zlib")

    add_urls("https://github.com/SFML/SFML/releases/download/$(version)/SFML-$(version)-sources.zip",
             "https://www.sfml-dev.org/files/SFML-$(version)-sources.zip")

    -- Before 2.6.0 only x86 is supported for Mac
    if not is_plat("macosx") or not is_arch("arm.*") then
        add_versions("2.5.1", "bf1e0643acb92369b24572b703473af60bac82caf5af61e77c063b779471bb7f")
    end

    add_versions("2.6.0", "dc477fc7266641709046bd38628c909f5748bd2564b388cf6c750a9e20cdfef1")

    add_configs("graphics",   {description = "Use the graphics module", default = true, type = "boolean"})
    add_configs("window",     {description = "Use the window module", default = true, type = "boolean"})
    add_configs("audio",      {description = "Use the audio module", default = true, type = "boolean"})
    add_configs("network",    {description = "Use the network module", default = true, type = "boolean"})
    if is_plat("windows", "mingw") then
        add_configs("main", {description = "Link to the sfml-main library", default = true, type = "boolean"})
    end

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    if is_plat("macosx") then
        add_extsources("brew::sfml/sfml-all")
    end

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

        if package:config("graphics") then
            package:add("deps", "freetype")
        end

        if package:is_plat("linux") then
            if package:config("window") or package:config("graphics") then
                package:add("deps", "libx11", "libxcursor", "libxext", "libxrandr", "libxrender", "eudev")
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

    on_install("windows", "linux", "macosx", "mingw", function (package)
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
