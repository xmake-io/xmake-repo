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

    add_versions("archive:3.2.0", "abe7114fa42edcc8097856787fa5d37f256d97e365b71368b60764fe7c10e4f8")
    add_versions("github:3.2.0", "release-3.2.0")

    add_deps("cmake")

    if is_plat("linux", "bsd") then
        add_configs("x11", {description = "Enables X11 support (requires it on the system)", default = true, type = "boolean"})
        add_configs("wayland", {description = "Enables Wayland support", default = true, type = "boolean"})
    end

    if is_plat("wasm") then
        add_cxflags("-sUSE_SDL=0")
    end

    on_load(function (package)
        if package:is_plat("windows") then
            package:add("deps", "ninja")
            package:set("policy", "package.cmake_generator.ninja", true)
        end
        if package:is_plat("linux", "bsd") and package:config("x11") then
            package:add("deps", "libxext", {private = true})
        end
        if package:is_plat("linux", "bsd") and package:config("wayland") then
            package:add("deps", "wayland", {private = true})
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
        local opt
        if package:is_plat("linux", "bsd", "cross") then
            local includedirs = {}
            for _, depname in ipairs({"libxext", "libx11", "xorgproto"}) do
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

                local cflags = {}
                opt = opt or {}
                opt.cflags = cflags
                for _, includedir in ipairs(includedirs) do
                    table.insert(cflags, "-I" .. includedir)
                end
                table.insert(configs, "-DCMAKE_INCLUDE_PATH=" .. table.concat(includedirs, ";"))
            end
        elseif package:is_plat("wasm") then
            -- emscripten enables USE_SDL by default which will conflict with the sdl headers
            opt = opt or {}
            opt.cflags = {"-sUSE_SDL=0"}
        end
        import("package.tools.cmake").install(package, configs, opt)
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
