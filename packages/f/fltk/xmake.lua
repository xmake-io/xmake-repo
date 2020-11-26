package("fltk")

    set_homepage("https://www.fltk.org")
    set_description("Fast Light Toolkit")
    set_urls("https://github.com/fltk/fltk/archive/d7985607d6dd8308f104d84c778080731fa23c9a.zip")
    add_versions("1.4.0", "43d398ab068732cb1debd9a98d124e47c9da6f53cdf3e36f22868a54cca0c371")
    add_deps("cmake")

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
        -- add_deps("libxft", "pango-1.0", "pangoxft-1.0", "gobject-2.0", "cairo", "pangocairo-1.0")
    end


    on_install("macosx", "windows", "mingw", "linux", "android", function (package)
        local configs = {}
        table.insert(configs, "-DOPTION_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DFLTK_BUILD_TEST=OFF")
        if package:is_plat("linux") then
            table.insert(configs, "-DOPTION_USE_PANGO=OFF") -- keep OFF until pango is available on xmake-repo
            table.insert(configs, "-DOPTION_USE_XFT=OFF") -- keep OFF until libxft is available on xmake-repo
        end
        if package:is_plat("android") then
            table.insert(configs, "-DOPTION_USE_SYSTEM_LIBPNG=OFF")
            table.insert(configs, "-DOPTION_USE_SYSTEM_ZLIB=OFF")
            table.insert(configs, "-DOPTION_USE_SYSTEM_LIBJPEG=OFF")
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
