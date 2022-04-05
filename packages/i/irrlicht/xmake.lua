package("irrlicht")

    set_homepage("https://irrlicht.sourceforge.io/")
    set_description("The Irrlicht Engine is an open source realtime 3D engine written in C++.")
    set_license("zlib")

    add_urls("https://downloads.sourceforge.net/irrlicht/irrlicht-$(version).zip")
    add_versions("1.8.5", "effb7beed3985099ce2315a959c639b4973aac8210f61e354475a84105944f3d")

    add_configs("tools", {description = "Build tools.", default = false, type = "boolean"})

    add_deps("bzip2", "libjpeg-turbo", "libpng", "zlib")
    if is_plat("windows") then
        add_syslinks("user32", "gdi32", "advapi32")
    elseif is_plat("macosx") then
        add_frameworks("Cocoa", "OpenGL", "IOKit")
    elseif is_plat("linux") then
        add_syslinks("GL")
        add_deps("libx11", "libxxf86vm", "libxcursor", "libxext")
    end
    on_load("windows", "macosx", "linux", function (package)
        if not package:config("shared") then
            package:add("defines", "_IRR_STATIC_LIB_")
        end
        if package:is_plat("macosx", "linux") and package:config("tools") then
            package:add("deps", "libxft")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {tools = package:config("tools")})
        if package:config("tools") then
            package:addenv("PATH", "bin")
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using namespace irr;
                IrrlichtDevice *device =
                    createDevice(video::EDT_SOFTWARE, core::dimension2d<u32>(640, 480), 16,
                        false, false, false, 0);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "irrlicht.h"}))
    end)
