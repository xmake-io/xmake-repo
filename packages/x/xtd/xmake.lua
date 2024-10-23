package("xtd")
    set_homepage("https://github.com/gammasoft71/xtd")
    set_description("xtd is a modern C++17/20 framework to create console, GUI (forms like WinForms) and unit test applications on Microsoft Windows, Apple macOS, Linux, iOS and android (*).")
    set_license("MIT")

    add_urls("https://github.com/gammasoft71/xtd/archive/refs/tags/$(version)-beta.zip",
             "https://github.com/gammasoft71/xtd.git")

    add_versions("v0.1.2", "648f7e5e2252d0db4e9432d493cec0682c059605ae3dfded793884cbbf3d1bd5")

    add_configs("graphic_toolkit", {description = "Select xtd graphic toolkit.", default = "wxwidgets", type = "string", values = {"gtk3", "wxwidgets", "fltk", "gtk4", "qt5"}})
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    -- when building the xtd shared library, it shows Cyclic dependencies error. I have summit a issue to xtd.
    -- https://github.com/gammasoft71/xtd/issues/264#issue-2527671013

    if is_plat("linux") then
        add_extsources("apt::libgsound-dev")
    end

    add_deps("cmake","alsa-lib", "xorgproto", "glib", "wxwidgets")

    on_load("linux", function (package)
        if package:config("graphic_toolkit") == "wxwidgets" then
            package:add("deps", "wxwidgets")
            package:add("deps", "gtk3")
        elseif package:config("graphic_toolkit") == "gtk3" then 
            package:add("deps", "gtk3")
        elseif package:config("graphic_toolkit") == "gtk4" then 
            package:add("deps", "gtk4")
        elseif package:config("graphic_toolkit") == "fltk" then
            package:add("deps", "fltk") 
        elseif package:config("graphic_toolkit") == "qt5" then 
            package:add("deps", "qt5base", "qt5core", "qt5gui", "qt5widgets")
        end
    end)    

    on_install("linux", function (package)
        -- io.replace("src/","", "" {plain=true})
        local configs = {"-DXTD_NATIVE_GRAPHIC_TOOLKIT=" .. package:config("graphic_toolkit"), "-DXTD_BUILD_TOOLS=OFF", "XTD_INSTALL_RESOURCES"}
        table.insert(configs, "-DXTD_BUILD_SHARED_LIBRARIES=" .. (package:config("shared") and "ON" or "OFF")) 
        table.insert(configs, "-DXTD_INSTALL_EXAMPLES=OFF")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <xtd/xtd>
            using namespace xtd;
            static void test() {
                console::background_color(console_color::blue);
                console::foreground_color(console_color::white);
                console::write_line("Hello, World!");
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
