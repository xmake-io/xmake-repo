package("simplewindow")
    set_homepage("https://mzying2001.github.io/sw/")
    set_description("SimpleWindow GUI Framework")
    set_license("MIT")

    add_urls("https://github.com/Mzying2001/sw/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Mzying2001/sw.git")
    
    add_versions("0.1.0", "cbf2f4717c5aa72c977071c9b37564b4626b0793baa12f421a714bfd73a8c951")
    add_versions("0.0.7", "b06d6d7840b40bac1c7c7c145d95c723a155581951b2ac3a6679b81b11a17adf")

    add_patches("0.0.7", path.join(os.scriptdir(), "patches", "0.0.7", "mingw.patch"), "b4c63bf701fdb05ec9220102feaec4b5bd5c676ccd54e0a9e2bce46c4039ac56")

    if is_plat("windows", "mingw") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_syslinks("gdi32", "user32", "shell32")

    add_includedirs("include", "include/sw")

    on_install("windows", "mingw@windows,msys", function (package)
        if package:has_tool("cxx", "cl") then
            package:add("cxxflags", "/source-charset:utf-8")
        end

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
