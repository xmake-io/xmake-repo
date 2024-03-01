package("sfgui")
    set_homepage("https://github.com/TankOs/SFGUI")
    set_description("Simple and Fast Graphical User Interface")
    set_license("zlib")

    add_deps("sfml")

    set_urls("https://github.com/TankOs/SFGUI.git")
    add_versions("0.4.0", "83471599284b2a23027b9ab4514684a6eeb08a19")
    
    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSFML_STATIC_LIBRARIES=YES")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            auto button1 = sfg::Button::Create();
        ]]}, { includes = { "SFGUI/SFGUI.hpp", "SFGUI/Widgets.hpp" } }))
    end)
