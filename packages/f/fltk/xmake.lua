package("fltk")
    set_homepage("https://www.fltk.org")
    set_description("Fast Light Toolkit")

    add_urls("https://github.com/fltk/fltk/archive/d7985607d6dd8308f104d84c778080731fa23c9a.zip",
             "https://github.com/fltk/fltk.git")

    add_versions("1.4.0", "43d398ab068732cb1debd9a98d124e47c9da6f53cdf3e36f22868a54cca0c371")

    if is_plat("linux") then
        add_configs("pango",   {description = "Use pango for font support", default = false, type = "boolean"})
        add_configs("xft",     {description = "Use libXft for font support", default = false, type = "boolean"})
    end
    add_configs("fluid", {description = "Build fluid", default = false, type = "boolean"})
    add_configs("forms", {description = "Build forms", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "comctl32", "gdi32", "oleaut32", "ole32", "uuid", "shell32", "advapi32", "comdlg32", "winspool", "user32", "kernel32", "odbc32")
    elseif is_plat("macosx") then 
        add_frameworks("Cocoa")
    elseif is_plat("android") then
        add_syslinks("android")
        add_syslinks("dl")
    else
        add_syslinks("dl", "pthread")
        add_deps("libx11", "libxext", "libxinerama", "libxcursor", "libxrender", "libxfixes", "fontconfig") 
    end

    add_deps("cmake")
    add_deps("zlib", "libpng", "libjpeg")

    on_load(function (package)
        if is_plat("linux") then
            if package:config("pango") then 
                package:add("deps", "pango-1.0", "pangoxft-1.0", "gobject-2.0", "cairo", "pangocairo-1.0")
            end
            if package:config("xft") then 
                package:add("deps", "libxft")
            end
        end
    end)

    on_install(function (package)
        for _, file in ipairs(os.files("**.cxx")) do
            io.replace(file, "<libpng/png.h>", "<png.h>", {plain = true})
        end

        local configs = {
            "-DFLTK_BUILD_TEST=OFF",
            "-DFLTK_BUILD_EXAMPLES=OFF",
            "-DOPTION_USE_SYSTEM_LIBPNG=ON",
            "-DOPTION_USE_SYSTEM_ZLIB=ON",
            "-DOPTION_USE_SYSTEM_LIBJPEG=ON"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DOPTION_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DFLTK_BUILD_FLUID=" .. (package:config("fluid") and "ON" or "OFF"))
        table.insert(configs, "-DFLTK_BUILD_FORMS=" .. (package:config("forms") and "ON" or "OFF"))
        if package:is_plat("linux") then
            table.insert(configs, "-DOPTION_USE_PANGO=" .. (package:config("pango") and "ON" or "OFF"))
            table.insert(configs, "-DOPTION_USE_XFT=" .. (package:config("xft") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "FL/Fl.H"
            #include "FL/Fl_Window.H"
            void test() {
                Fl_Window *win = new Fl_Window(400, 300);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
