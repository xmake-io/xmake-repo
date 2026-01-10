package("libsdl3")
    set_homepage("https://www.libsdl.org/")
    set_description("Simple DirectMedia Layer")
    set_license("zlib")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::SDL3")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl3", "apt::libsdl3-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl3")
    end

    add_urls("https://www.libsdl.org/release/SDL3-$(version).zip",
             "https://github.com/libsdl-org/SDL/releases/download/release-$(version)/SDL3-$(version).zip", { alias = "archive" })
    add_urls("https://github.com/libsdl-org/SDL.git", { alias = "github" })

    add_versions("archive:3.4.0", "9ac2debb493e0d3e13dbd2729fb91f4bfeb00a0f4dff5e04b73cc9bac276b38d")
    add_versions("archive:3.2.28", "24a30069af514a6c6b773bdc8ccca8b321661b251381acc1daeebf8c8f4a109a")
    add_versions("archive:3.2.26", "739356eef1192fff9d641c320a8f5ef4a10506b8927def4b9ceb764c7e947369")
    add_versions("archive:3.2.22", "3d60068b1e5c83c66bb14c325dfef46f8fcc380735b4591de6f5e7b9738929d1")
    add_versions("archive:3.2.16", "0cc7430fb827c1f843e31b8b26ba7f083b1eeb8f6315a65d3744fd4d25b6c373")
    add_versions("archive:3.2.14", "46a17d3ea71fe2580a7f43ca7da286c5b9106dd761e2fd5533bb113e5d86b633")
    add_versions("archive:3.2.10", "01d9ab20fc071b076be91df5396b464b4ef159e93b2b2addda1cc36750fc1f29")
    add_versions("archive:3.2.8", "7f8ff5c8246db4145301bc122601a5f8cef25ee2c326eddb3e88668849c61ddf")
    add_versions("archive:3.2.6", "665e5aa2a613affe099a38d61257ecc5ef4bf38b109d915147aa8b005399d68a")
    add_versions("archive:3.2.2", "58d8adc7068d38923f918e0bdaa9c4948f93d9ba204fe4de8cc6eaaf77ad6f82")
    add_versions("archive:3.2.0", "abe7114fa42edcc8097856787fa5d37f256d97e365b71368b60764fe7c10e4f8")

    add_versions("github:3.4.0", "release-3.4.0")
    add_versions("github:3.2.28", "release-3.2.28")
    add_versions("github:3.2.26", "release-3.2.26")
    add_versions("github:3.2.22", "release-3.2.22")
    add_versions("github:3.2.16", "release-3.2.16")
    add_versions("github:3.2.14", "release-3.2.14")
    add_versions("github:3.2.10", "release-3.2.10")
    add_versions("github:3.2.8", "release-3.2.8")
    add_versions("github:3.2.6", "release-3.2.6")
    add_versions("github:3.2.2", "release-3.2.2")
    add_versions("github:3.2.0", "release-3.2.0")

    add_patches("3.4.0", "patches/3.4.0/fix-ios.patch", "feffa146aa825f97fc431f115f3990a7a0ad0214d05a9765f2cfbd3633465bf8")

    add_deps("cmake", "egl-headers", "opengl-headers")

    if is_plat("linux", "bsd", "cross") then
        add_configs("x11", {description = "Enables X11 support", default = true, type = "boolean"})
        add_configs("x11_shared", {description = "Dynamically load X11 support", default = true, type = "boolean"})
        add_configs("wayland", {description = "Enables Wayland support", default = nil, type = "boolean"})
        add_configs("wayland_shared", {description = "Dynamically load Wayland support", default = true, type = "boolean"})
    end

    if is_plat("wasm") then
        add_cxflags("-sUSE_SDL=0")
    end

    on_load(function (package)
        if package:is_plat("linux", "android", "cross") then
            -- Enable Wayland by default except when cross-compiling (wayland package doesn't support cross-compilation yet)
            if package:config("wayland") == nil and not package:is_cross() then
                package:config_set("wayland", true)
            end
        end
        if package:is_plat("windows") then
            package:add("deps", "ninja")
            package:set("policy", "package.cmake_generator.ninja", true)
        end
        if package:is_plat("linux", "bsd", "cross") and package:config("x11") then
            local deplibs = {"libx11", "libxcb", "libxext", "libxcursor", "libxfixes", "libxi", "libxrandr", "libxrender", "libxss"}
            local depconfig = package:config("x11_shared") and {private = true, configs = {shared = true}} or nil
            for _, lib in ipairs(deplibs) do
                package:add("deps", lib, depconfig)
            end
        end
        if package:is_plat("linux", "bsd", "cross") and package:config("wayland") then
            if package:config("wayland_shared") then
                package:add("deps", "wayland", {private = true, configs = {shared = true}})
            else
                package:add("deps", "wayland")
            end
        end
        local libsuffix = package:is_debug() and "d" or ""
        if not package:config("shared") then
            if package:is_plat("windows", "mingw") then
                package:add("syslinks", "user32", "gdi32", "winmm", "imm32", "ole32", "oleaut32", "version", "uuid", "advapi32", "setupapi", "shell32")
            elseif package:is_plat("linux", "bsd") then
                package:add("syslinks", "pthread", "dl")
                if package:is_plat("bsd") then
                    package:add("syslinks", "usbhid")
                end
            elseif package:is_plat("android") then
                package:add("syslinks", "dl", "log", "android", "GLESv1_CM", "GLESv2", "OpenSLES")
            elseif package:is_plat("iphoneos", "macosx") then
                package:add("frameworks", "AudioToolbox", "AVFoundation", "CoreAudio", "CoreHaptics", "CoreMedia", "CoreVideo", "Foundation", "GameController", "Metal", "QuartzCore", "CoreFoundation", "UniformTypeIdentifiers")
		        package:add("syslinks", "iconv")
                if package:is_plat("macosx") then
                    package:add("frameworks", "Cocoa", "Carbon", "ForceFeedback", "IOKit")
                else
                    package:add("frameworks", "CoreBluetooth", "CoreGraphics", "CoreMotion", "OpenGLES", "UIKit")
                end
		    end
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSDL_TEST_LIBRARY=OFF")
        table.insert(configs, "-DSDL_EXAMPLES=OFF")
        if package:is_plat("linux", "bsd", "cross") then
            table.insert(configs, "-DSDL_X11=" .. (package:config("x11") and "ON" or "OFF"))
            table.insert(configs, "-DSDL_X11_SHARED=" .. (package:config("x11_shared") and "ON" or "OFF"))
            table.insert(configs, "-DSDL_X11_XTEST=OFF")
            table.insert(configs, "-DSDL_WAYLAND=" .. (package:config("wayland") and "ON" or "OFF"))
            table.insert(configs, "-DSDL_WAYLAND_SHARED=" .. (package:config("wayland_shared") and "ON" or "OFF"))
        end

        local cflags
        local packagedeps
        if not package:is_plat("wasm") then
            packagedeps = table.join2(packagedeps or {}, {"egl-headers", "opengl-headers"})
        end

        if package:is_plat("linux", "bsd", "cross") then
            packagedeps = table.join2(packagedeps or {}, {"libxcursor", "libxext", "libxfixes", "libxcb", "libx11", "libxi", "libxrandr", "libxrender", "libxss", "xorgproto", "wayland"})
        elseif package:is_plat("wasm") then
            -- emscripten enables USE_SDL by default which will conflict with libsdl headers
            cflags = {"-sUSE_SDL=0"}
        end

        local includedirs = {}
        for _, depname in ipairs(packagedeps) do
            local dep = package:dep(depname)
            if dep then
                local depfetch = dep:fetch()
                if depfetch then
                    for _, includedir in ipairs(depfetch.includedirs or depfetch.sysincludedirs) do
                        table.insert(includedirs, includedir)
                    end
                end
            end
        end
        if #includedirs > 0 then
            includedirs = table.unique(includedirs)
            table.insert(configs, "-DCMAKE_INCLUDE_PATH=" .. table.concat(includedirs, ";"))
            cflags = cflags or {}
            for _, includedir in ipairs(includedirs) do
                table.insert(cflags, "-I" .. includedir)
            end
        end
        import("package.tools.cmake").install(package, configs, {cflags = cflags})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <SDL3/SDL.h>
            int main(int argc, char** argv) {
                SDL_Init(0);
                SDL_Quit();
                return 0;
            }
        ]]}));
    end)
