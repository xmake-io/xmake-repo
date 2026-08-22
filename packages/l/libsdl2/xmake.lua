package("libsdl2")
    set_homepage("https://www.libsdl.org/")
    set_description("Simple DirectMedia Layer")
    set_license("zlib")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::SDL2")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl2", "apt::libsdl2-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl2")
    end

    add_urls("https://www.libsdl.org/release/SDL2-$(version).zip",
             "https://github.com/libsdl-org/SDL/releases/download/release-$(version)/SDL2-$(version).zip", { alias = "archive" })
    add_urls("https://github.com/libsdl-org/SDL.git", { alias = "github" })

    add_versions("archive:2.0.8", "e6a7c71154c3001e318ba7ed4b98582de72ff970aca05abc9f45f7cbdc9088cb")
    add_versions("archive:2.0.12", "476e84d6fcbc499cd1f4a2d3fd05a924abc165b5d0e0d53522c9604fe5a021aa")
    add_versions("archive:2.0.14", "2c1e870d74e13dfdae870600bfcb6862a5eab4ea5b915144aff8d75a0f9bf046")
    add_versions("archive:2.0.16", "010148866e2226e5469f2879425d28ff7c572c736cb3fb65a0604c3cde6bfab9")
    add_versions("archive:2.0.18", "2d96cc82020341f7f5957c42001ad526e15fbb7056be8a74dab302483e97aa24")
    add_versions("archive:2.0.20", "cc8b16a326eb082c1f48ca30fdf471acfd2334b69bd7527e65ac58369013a1ba")
    add_versions("archive:2.0.22", "9a81ab724e6dcef96c61a4a2ebe7758e5b8bb191794650d276a20d5148fbd50c")
    add_versions("archive:2.24.0", "4b065503d45652d5f65d807fe98c757c73af2968727945b596861995bc3b69c2")
    add_versions("archive:2.24.2", "7fae98ac4e7b39eb2511fc27c2e84b220ac69b5296ff41f833b967c891f9d2ac")
    add_versions("archive:2.26.0", "4a181f158f88676816e4993d7e97e7b48ef273aa6f4e2909c6a85497e9af3e9f")
    add_versions("archive:2.26.1", "c038222fcac6ccc448daaa3febcae93fdac401aed12fd60da3b7939529276b1b")
    add_versions("archive:2.26.2", "31510e53266c9e4730070ec20543c25642a85db7f678445cd9cfc61c7b6eb94b")
    add_versions("archive:2.26.3", "3e46df1eb1be30448cf7c7f3fc0991980f0ef867c2412ab7bc925b631e5dc09c")
    add_versions("archive:2.26.4", "f22fd1410a4b4345f2da679b372629da38f644a686660f1ebadc5e0cb05a7369")
    add_versions("archive:2.26.5", "d88362fc3ee350a037e31381db00df764a294244bac8e427b8c67c6ca4d7e6fd")
    add_versions("archive:2.28.0", "a3fd9394093e08ae47233353c1efb07b28514fe63d7caed34b7811e8a17e5731")
    add_versions("archive:2.28.1", "b34b6f5a4d38191491724698a62241f0264c8a56c7d550fd49d1daf49261ae46")
    add_versions("archive:2.28.2", "22383a6b242bac072f949d2b3854cf04c6856cae7a87eaa78c60dd733b71e41e")
    add_versions("archive:2.28.3", "2308d4e4cd5852b3b81934dcc94603454834c14bef49de1cb1230c37ea6dc15c")
    add_versions("archive:2.28.4", "b53b9b42e731a33552d0a533316a88009b423c16a8a3a418df9ffe498c37da3d")
    add_versions("archive:2.28.5", "97bd14ee0ec67494d2b93f1a4f7da2bf891103c57090d96fdcc2b019d885c76a")
    add_versions("archive:2.30.0", "80b0c02b6018630cd40639ac9fc8e5c1d8eec14d8fe3e6dfa76343e3ba8b78d9")
    add_versions("archive:2.30.1", "c15ded54e9f32f8a1f9ed3e3dc072837a320ed23c5d0e95b7c18ecbe05c1187b")
    add_versions("archive:2.30.2", "09a822abf6e97f80d09cf9c46115faebb3476b0d56c1c035aec8ec3f88382ae7")
    add_versions("archive:2.30.3", "c5d78a9e0346c6695f03df8ba25e5e111a1e23c8aefa8372a1c5a0dd79acaf10")
    add_versions("archive:2.30.4", "292d5e2f897aa3acb6b365b605c3249c92916fbe7eba4a2e57573ada3855d7cb")
    add_versions("archive:2.30.5", "688d3da2bf7e887d0ba8e0f81c926119f85029544f4f6da8dea96db70f9d28e3")
    add_versions("archive:2.30.6", "6d4e00fcbee9fd8985cc2869edeb0b1a751912b87506cf2fb6471e73d981e1f4")
    add_versions("archive:2.30.7", "e5d592a60c1a4428095af323849e207e93cfbbe7a94931db526ce1213a2effed")
    add_versions("archive:2.30.8", "abe2921dffcb25d39d270454810b211a9f47be3e5e802bc45e7d058f286a325e")
    add_versions("archive:2.30.9", "ec855bcd815b4b63d0c958c42c2923311c656227d6e0c1ae1e721406d346444b")
    add_versions("archive:2.30.10", "14b06b30d3400953875e73b0c4771cad1483488a1ef816803610f22b32300ce8")
    add_versions("archive:2.32.2", "926718a165e9927e2045c0f0e2b02f6d8d73101ff82d27a066855fdd9a5fb952")
    add_versions("archive:2.32.10", "12b2dc2eb8f2836100a7916b5d394a0c82f1f7e32693f95f98305403af242f08")

    add_versions("github:2.0.8",  "release-2.0.8")
    add_versions("github:2.0.12", "release-2.0.12")
    add_versions("github:2.0.14", "release-2.0.14")
    add_versions("github:2.0.16", "release-2.0.16")
    add_versions("github:2.0.18", "release-2.0.18")
    add_versions("github:2.0.20", "release-2.0.20")
    add_versions("github:2.0.22", "release-2.0.22")
    add_versions("github:2.24.0", "release-2.24.0")
    add_versions("github:2.24.2", "release-2.24.2")
    add_versions("github:2.26.0", "release-2.26.0")
    add_versions("github:2.26.1", "release-2.26.1")
    add_versions("github:2.26.2", "release-2.26.2")
    add_versions("github:2.26.3", "release-2.26.3")
    add_versions("github:2.26.4", "release-2.26.4")
    add_versions("github:2.26.5", "release-2.26.5")
    add_versions("github:2.28.0", "release-2.28.0")
    add_versions("github:2.28.1", "release-2.28.1")
    add_versions("github:2.28.2", "release-2.28.2")
    add_versions("github:2.28.3", "release-2.28.3")
    add_versions("github:2.28.4", "release-2.28.4")
    add_versions("github:2.28.5", "release-2.28.5")
    add_versions("github:2.30.0", "release-2.30.0")
    add_versions("github:2.30.1", "release-2.30.1")
    add_versions("github:2.30.2", "release-2.30.2")
    add_versions("github:2.30.3", "release-2.30.3")
    add_versions("github:2.30.4", "release-2.30.4")
    add_versions("github:2.30.5", "release-2.30.5")
    add_versions("github:2.30.6", "release-2.30.6")
    add_versions("github:2.30.7", "release-2.30.7")
    add_versions("github:2.30.8", "release-2.30.8")
    add_versions("github:2.30.9", "release-2.30.9")
    add_versions("github:2.30.10", "release-2.30.10")
    add_versions("github:2.32.2", "release-2.32.2")
    add_versions("github:2.32.10", "release-2.32.10")

    add_patches("2.30.0", "patches/2.30.0/fix_mingw.patch", "ab54eebc2e58d88653b257bc5b48a232c5fb0e6fad5d63661b6388215a7b0cd0")
    add_patches("2.30.6", "https://github.com/libsdl-org/SDL/commit/7cf3234efeb7a68636bcfdfb3b1507b43fbb0845.patch", "c2fba1e76f8f10631544b63e8ce105a67d582b23bba7c96bdef5f135bd6b4cad")
    add_patches("2.32.2", "patches/2.32.2/fix-arm64.patch", "11ba63e6f93299030750afd26234da63c534f6cb0f10f9e87bd4efb248768261")

    add_deps("cmake")

    add_includedirs("include", "include/SDL2")

    if is_plat("android") then
        add_configs("sdlmain", {description = "Use SDL_main entry point", default = false, type = "boolean", readonly = true})
    else
        add_configs("sdlmain", {description = "Use SDL_main entry point", default = true, type = "boolean"})
    end

    if is_plat("linux", "bsd", "cross") then
        add_configs("x11", {description = "Enables X11 support (requires it on the system)", default = true, type = "boolean"})
        add_configs("wayland", {description = "Enables Wayland support", default = nil, type = "boolean"})

        -- @note deprecated
        add_configs("with_x", {description = "Enables X support (requires it on the system)", default = true, type = "boolean"})
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
        if package:config("sdlmain") then
            package:add("components", "main")
            if package:is_plat("mingw") then
                -- MinGW requires linking mingw32 before SDL2main
                local libsuffix = package:is_debug() and "d" or ""
                package:add("linkorders", "mingw32", "SDL2main" .. libsuffix)
            end
        else
            package:add("defines", "SDL_MAIN_HANDLED")
        end
        package:add("components", "lib")
        if package:is_plat("linux", "bsd") and (package:config("x11") or package:config("with_x")) then
            package:add("deps", "libxext", {private = true})
        end
        if package:is_plat("linux", "bsd") and package:config("wayland") then
            package:add("deps", "wayland", {private = true})
        end
    end)

    on_component("main", function (package, component)
        local libsuffix = package:is_debug() and "d" or ""
        component:add("links", "SDL2main" .. libsuffix)
        if package:is_plat("windows") then
            component:add("syslinks", "shell32")
        elseif package:is_plat("mingw") then
            component:add("syslinks", "mingw32")
        end
        component:add("deps", "lib")
    end)

    on_component("lib", function (package, component)
        local libsuffix = package:is_debug() and "d" or ""
        if package:config("shared") then
            component:add("links", "SDL2" .. libsuffix)
        else
            component:add("links", (package:is_plat("windows") and "SDL2-static" or "SDL2") .. libsuffix)
            if package:is_plat("windows", "mingw") then
                component:add("syslinks", "user32", "gdi32", "winmm", "imm32", "ole32", "oleaut32", "version", "uuid", "advapi32", "setupapi", "shell32")
            elseif package:is_plat("linux", "bsd") then
                component:add("syslinks", "pthread", "dl")
                if package:is_plat("bsd") then
                    component:add("syslinks", "usbhid")
                end
            elseif package:is_plat("android") then
                component:add("syslinks", "dl", "log", "android", "GLESv1_CM", "GLESv2", "OpenSLES")
            elseif package:is_plat("iphoneos", "macosx") then
                component:add("frameworks", "AudioToolbox", "AVFoundation", "CoreAudio", "CoreVideo", "Foundation", "Metal", "QuartzCore", "CoreFoundation")
		        component:add("syslinks", "iconv")
                if package:is_plat("macosx") then
                    component:add("frameworks", "Cocoa", "Carbon", "ForceFeedback", "IOKit")
                else
                    component:add("frameworks", "CoreBluetooth", "CoreGraphics", "CoreMotion", "OpenGLES", "UIKit")
		        end
                if package:version():ge("2.0.14") then
                    package:add("frameworks", "CoreHaptics", "GameController")
                end
            end
        end
    end)

    on_fetch("linux", "macosx", "bsd", function (package, opt)
        if opt.system then
            -- use sdl2-config
            local sdl2conf = try {function() return os.iorunv("sdl2-config", {"--version", "--cflags", "--libs"}) end}
            if sdl2conf then
                sdl2conf = os.argv(sdl2conf)
                local sdl2ver = table.remove(sdl2conf, 1)
                local result = {version = sdl2ver}
                for _, flag in ipairs(sdl2conf) do
                    if flag:startswith("-L") and #flag > 2 then
                        -- get linkdirs
                        local linkdir = flag:sub(3)
                        if linkdir and os.isdir(linkdir) then
                            result.linkdirs = result.linkdirs or {}
                            table.insert(result.linkdirs, linkdir)
                        end
                    elseif flag:startswith("-I") and #flag > 2 then
                        -- get includedirs
                        local includedir = flag:sub(3)
                        if includedir and os.isdir(includedir) then
                            result.includedirs = result.includedirs or {}
                            table.insert(result.includedirs, includedir)
                        end
                    elseif flag:startswith("-l") and #flag > 2 then
                        -- get links
                        local link = flag:sub(3)
                        result.links = result.links or {}
                        table.insert(result.links, link)
                    elseif flag:startswith("-D") and #flag > 2 then
                        -- get defines
                        local define = flag:sub(3)
                        result.defines = result.defines or {}
                        table.insert(result.defines, define)
                    end
                end

                return result
            end

            -- finding using sdl2-config didn't work, fallback on pkgconfig
            if package.find_package then
                return package:find_package("pkgconfig::sdl2", opt)
            else
                return find_package("pkgconfig::sdl2", opt)
            end
        end
    end)

    on_install(function (package)
        if os.isfile("src/sensor/android/SDL_androidsensor.c") then
            io.replace("src/sensor/android/SDL_androidsensor.c", "ALooper_pollAll", "ALooper_pollOnce", {plain = true})
        end
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSDL_TEST=OFF")
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
            #include <SDL2/SDL.h>
            int main(int argc, char** argv) {
                SDL_Init(0);
                return 0;
            }
        ]]}, {configs = {defines = "SDL_MAIN_HANDLED"}}));
    end)
