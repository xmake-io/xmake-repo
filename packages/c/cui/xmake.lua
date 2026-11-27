package("cui")
    set_homepage("https://github.com/yappologistic/CUI")
    set_description("Native UI components for C, with spring motion and full keyboard support")
    set_license("MIT")

    add_urls("https://github.com/yappologistic/CUI/archive/refs/tags/$(version).tar.gz")
    add_versions("v1.5.0", "3fe33f12c12562c5b32998afe4334608083eed789d93617b06fe7461c32ea662")

    add_deps("cmake")

    -- CUI_WITH_APP=ON pulls in the native window backend, which links these system libraries.
    if is_plat("linux") then
        add_deps("libx11")
        add_syslinks("dl", "m", "pthread")
    elseif is_plat("macosx") then
        add_frameworks("Cocoa", "QuartzCore", "OpenGL")
    elseif is_plat("windows", "mingw") then
        add_syslinks("user32", "gdi32", "opengl32", "shell32", "imm32", "dwmapi",
                     "comdlg32", "ole32", "advapi32")
    end

    on_install("windows", "mingw", "linux", "macosx", function (package)
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            -- CUI uses CUI_BUILD_SHARED, not BUILD_SHARED_LIBS.
            "-DCUI_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"),
            -- xmake configures the package source as a top-level CMake project,
            -- where examples/tests default to ON.
            "-DCUI_BUILD_EXAMPLES=OFF",
            "-DCUI_BUILD_TESTS=OFF",
            "-DCUI_WITH_APP=ON"
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cincludes("cui/cui.h"))
        assert(package:has_cfuncs("cui_app_create", {includes = {"cui/cui.h", "cui/cui_app.h"}}))
    end)
