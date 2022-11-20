package("libsdl")

    set_homepage("https://www.libsdl.org/")
    set_description("Simple DirectMedia Layer")
	
    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::SDL2")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl2", "apt::libsdl2-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl2")
    end

    set_license("zlib")

    if is_plat("windows", "mingw") then
        set_urls("https://www.libsdl.org/release/SDL2-devel-$(version)-VC.zip")
        add_urls("https://github.com/libsdl-org/SDL/releases/download/release-$(version)/SDL2-devel-$(version)-VC.zip")
        add_versions("2.0.8", "68505e1f7c16d8538e116405411205355a029dcf2df738dbbc768b2fe95d20fd")
        add_versions("2.0.12", "00c55a597cebdb9a4eb2723f2ad2387a4d7fd605e222c69b46099b15d5d8b32d")
        add_versions("2.0.14", "232071cf7d40546cde9daeddd0ec30e8a13254c3431be1f60e1cdab35a968824")
        add_versions("2.0.16", "f83651227229e059a570aac26be24f5070352c0d23aaf3d2cfbd3eb2c9599334")
        add_versions("2.0.18", "d4a56e2ee7c0eae2ef0d511201d3bd38c5ab255662e4b571d4d630762473bf42")
        add_versions("2.0.20", "5b1512ca6c9d2427bd2147da01e5e954241f8231df12f54a7074dccde416df18")
        add_versions("2.0.22", "32adc96d8b25e5671189f1f38a4fc7deb105fbb1b3ed78ffcb23f5b8f36b3922")
        add_versions("2.24.0", "97c6e2d17c0baebf4c84ede27ec42e211358f3694b9f558ead3a9c542c4a004e")
        add_versions("2.24.2", "fae7f8f1661fc1fb3ece7b58eca3b2aaeb2ed000a0b7766f859ae12511efd11f")
    else
        set_urls("https://www.libsdl.org/release/SDL2-$(version).zip")
        add_urls("https://github.com/libsdl-org/SDL/releases/download/release-$(version)/SDL2-$(version).zip")
        add_versions("2.0.8", "e6a7c71154c3001e318ba7ed4b98582de72ff970aca05abc9f45f7cbdc9088cb")
        add_versions("2.0.12", "476e84d6fcbc499cd1f4a2d3fd05a924abc165b5d0e0d53522c9604fe5a021aa")
        add_versions("2.0.14", "2c1e870d74e13dfdae870600bfcb6862a5eab4ea5b915144aff8d75a0f9bf046")
        add_versions("2.0.16", "010148866e2226e5469f2879425d28ff7c572c736cb3fb65a0604c3cde6bfab9")
        add_versions("2.0.18", "2d96cc82020341f7f5957c42001ad526e15fbb7056be8a74dab302483e97aa24")
        add_versions("2.0.20", "cc8b16a326eb082c1f48ca30fdf471acfd2334b69bd7527e65ac58369013a1ba")
        add_versions("2.0.22", "9a81ab724e6dcef96c61a4a2ebe7758e5b8bb191794650d276a20d5148fbd50c")
        add_versions("2.24.0", "4b065503d45652d5f65d807fe98c757c73af2968727945b596861995bc3b69c2")
        add_versions("2.24.2", "7fae98ac4e7b39eb2511fc27c2e84b220ac69b5296ff41f833b967c891f9d2ac")
    end

    if is_plat("macosx") then
        add_frameworks("OpenGL", "CoreVideo", "CoreAudio", "AudioToolbox", "Carbon", "CoreGraphics", "ForceFeedback", "Metal", "AppKit", "IOKit", "CoreFoundation", "Foundation")
        add_syslinks("iconv")
    elseif is_plat("linux", "bsd") then
        if is_plat("bsd") then
	        add_deps("libusb")
            add_syslinks("usbhid")
        end
        add_syslinks("pthread", "dl")
    elseif is_plat("windows", "mingw") then
        add_syslinks("gdi32", "user32", "winmm", "shell32")
    end
    add_includedirs("include", "include/SDL2")

    add_configs("use_sdlmain", {description = "Use SDL_main entry point", default = true, type = "boolean"})
    if is_plat("windows", "mingw") then
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})
    elseif is_plat("linux") then
        add_configs("with_x", {description = "Enables X support (requires it on the system)", default = true, type = "boolean"})
    end

    on_load(function (package)
        if package:config("use_sdlmain") then
            package:add("links", "SDL2main", "SDL2")
            package:add("defines", "SDL_MAIN_HANDLED")
        else
            package:add("links", "SDL2")
        end
        if package:is_plat("linux") and package:config("with_x") then
            package:add("deps", "libxext", {private = true})
        end
        if package:is_plat("macosx") and package:version():ge("2.0.14") then
            package:add("frameworks", "CoreHaptics", "GameController")
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

    on_install("windows", "mingw", function (package)
        local arch = package:arch()
        if package:is_plat("mingw") then
            arch = (arch == "x86_64") and "x64" or "x86"
        end
        os.cp("include/*", package:installdir("include/SDL2"))
        os.cp(path.join("lib", arch, "*.lib"), package:installdir("lib"))
        os.cp(path.join("lib", arch, "*.dll"), package:installdir("bin"))
    end)

    on_install("macosx", "linux", "bsd", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        local opt
        if package:is_plat("linux") then
            local cflags = {}
            opt = opt or {}
            opt.cflags = cflags
            for _, depname in ipairs({"libxext", "libx11", "xorgproto"}) do
                local dep = package:dep(depname)
                if dep then
                    local depfetch = dep:fetch()
                    if depfetch then
                        for _, includedir in ipairs(depfetch.includedirs or depfetch.sysincludedirs) do
                            table.join2(cflags, "-I" .. includedir)
                        end
                    end
                end
            end
        elseif package:is_plat("bsd") then
            opt = opt or {}
            opt.packagedeps = "libusb"
        end
        import("package.tools.autoconf").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SDL_Init", {includes = "SDL2/SDL.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
