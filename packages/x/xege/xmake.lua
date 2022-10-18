package("xege")

    set_homepage("https://xege.org")
    set_description("Easy Graphics Engine, a lite graphics library in Windows")
    set_license("LGPL-2.1")

    add_urls("https://github.com/wysaid/xege.git",
             "https://gitee.com/xege/xege.git")
    
    add_versions("v2020.08.31", "40bca13799e512b14570c41f3d285eca616ca9b1")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")

    if is_arch("x86", "i386", "arm") then
        add_links("graphics")
    else
        add_links("graphics64")
    end

    add_syslinks("gdiplus", "uuid", "msimg32", "gdi32", "imm32", "ole32", "oleaut32")

    on_install("windows", "mingw", function (package)
        local configs = {}
        local mode = (package:debug() and "Debug" or "Release")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. mode)

        import("package.tools.cmake").build(package, configs, {buildir = "build"})

        os.trycp("build/" .. mode .. "/*.lib", package:installdir("lib"))
        os.trycp("build/*.a", package:installdir("lib"))
        os.cp("src/*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cassert>
            #include <graphics.h>
            static void test() {
                initgraph(640, 480);
                circle(200, 200, 100);
                assert(is_run());
                closegraph();
            }
        ]]}))
    end)
