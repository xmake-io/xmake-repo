package("fltk")
    set_homepage("https://www.fltk.org")
    set_description("Fast Light Toolkit")

    add_urls("https://www.fltk.org/pub/fltk/$(version)/fltk-$(version)-source.tar.bz2", {alias = "home"})
    add_urls("https://github.com/fltk/fltk/archive/refs/tags/release-$(version).tar.gz", {alias = "github"})
    add_urls("https://github.com/fltk/fltk.git")

    add_versions("home:1.3.9", "103441134915402808fd45424d4061778609437e804334434e946cfd26b196c2")
    add_versions("github:1.3.9", "f30661851a61f1931eaaceb9ef4005584c85cb07fd7ffc38a645172b8e4eb3df")

    add_patches("1.3.9", "patches/1.3.9/cmake-fluid.patch", "06ee1e82a74651a0b4ba4b386e5e5436d8b95584330d02a8a2c53351210a9127")

    if is_plat("linux") then
        add_configs("pango", {description = "Use pango for font support", default = false, type = "boolean"})
        add_configs("xft", {description = "Use libXft for font support", default = false, type = "boolean"})
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
    elseif is_plat("linux") then
        add_syslinks("dl", "pthread")
        add_deps("libx11", "libxext", "libxinerama", "libxcursor", "libxrender", "libxfixes", "fontconfig") 
    end

    add_deps("cmake")
    add_deps("zlib", "libpng", "libjpeg")

    on_load(function (package)
        if package:is_plat("linux") then
            if package:version() and package:version():eq("1.3.9") then
                assert(not package:config("fluid"), "package(fltk/1.3.9): Unsupported fluid on linux")
            end
            if package:config("pango") then 
                package:add("deps", "pango-1.0", "pangoxft-1.0", "gobject-2.0", "cairo", "pangocairo-1.0")
            end
            if package:config("xft") then 
                package:add("deps", "libxft")
            end
        end
    end)

    on_install("windows|x86", "windows|x64", "linux", "macosx", "mingw", "msys", function (package)
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
        table.insert(configs, "-DFLTK_MSVC_RUNTIME_DLL=" .. (package:has_runtime("MD") and "ON" or "OFF"))
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
