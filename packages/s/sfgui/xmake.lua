package("sfgui")
    set_homepage("https://github.com/TankOs/SFGUI")
    set_description("Simple and Fast Graphical User Interface")
    set_license("zlib")

    add_urls("https://github.com/TankOs/SFGUI/archive/refs/tags/$(version).tar.gz",
             "https://github.com/TankOs/SFGUI.git")

    add_versions("1.0.0", "280993756cfa8ca82574a5c505f4ce65f192037d523d38572552e96ca18aa3a0")

    add_configs("font", {description = "Include default font in library (DejaVuSans)", default = true, type = "boolean"})

    if is_plat("mingw") then
        add_deps("sfml", {configs = {graphics = true, shared = true}})
    else
        add_deps("sfml", {configs = {graphics = true}})
    end

    add_deps("opengl")

    if is_plat("linux", "bsd", "cross") then
        add_deps("libx11")
    end

    if is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation", "Foundation")
    end

    on_install("windows", "linux", "macosx", "mingw", function (package)
        io.replace("include/SFGUI/Config.hpp", "defined( SFGUI_STATIC )", not package:config("shared") and "1" or "0", {plain = true})
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                sfg::Window::Ptr window = sfg::Window::Create();
	            window->SetTitle( "Title" );
            }
        ]]}, {configs = {languages = "c++17"}, includes = { "SFGUI/SFGUI.hpp", "SFGUI/Widgets.hpp" } }))
    end)
