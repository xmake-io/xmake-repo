package("simplewindow")
    set_homepage("https://mzying2001.github.io/sw/")
    set_description("SimpleWindow GUI Framework")
    set_license("MIT")

    add_urls("https://github.com/Mzying2001/sw.git")
    add_versions("2025.03.17", "6d64fd992c7243660598811beaac9d586a918b20")

    if is_plat("windows", "mingw") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_syslinks("gdi32", "user32", "shell32")

    add_includedirs("include", "include/sw")

    on_install("windows", "mingw@windows,msys", function (package)
        os.cd("sw")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                sw::Window mainWindow;
                auto msg = sw::App::MsgLoop();
            }
        ]]}, {includes = "SimpleWindow.h", configs = {languages = "c++14"}}))
    end)
