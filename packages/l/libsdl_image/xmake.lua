package("libsdl_image")
    set_homepage("http://www.libsdl.org/projects/SDL_image/")
    set_description("Simple DirectMedia Layer image loading library")
    set_license("zlib")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::SDL2_image")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl2_image", "apt::libsdl2-image-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl2_image")
    end

    add_urls("https://www.libsdl.org/projects/SDL_image/release/SDL2_image-$(version).zip",
             "https://github.com/libsdl-org/SDL_image/releases/download/release-$(version)/SDL2_image-$(version).zip")
    add_versions("2.6.0", "2252cdfd5be73cefaf727edc39c2ef3b7682e797acbd3126df117e925d46aaf6")
    add_versions("2.6.1", "cbfea63a46715c63a1db9e41617e550749a95ffd33ef9bd5ba6e58b2bdca6ed3")
    add_versions("2.6.2", "efe3c229853d0d40c35e5a34c3f532d5d9728f0abc623bc62c962bcef8754205")

    if is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation", "CoreGraphics", "ImageIO", "CoreServices")
    elseif is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    add_includedirs("include", "include/SDL2")

    on_load(function (package)
        if package:config("shared") then
            package:add("deps", "libsdl", { configs = { shared = true }})
        else
            package:add("deps", "libsdl")
        end
    end)

    on_install(function (package)
        local configs = {"-DSDL2IMAGE_SAMPLES=OFF", "-DSDL2IMAGE_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        local libsdl = package:dep("libsdl")
        if libsdl and not libsdl:is_system() then
            table.insert(configs, "-DSDL2_DIR=" .. libsdl:installdir())
            local fetchinfo = libsdl:fetch()
            if fetchinfo then
                for _, dir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    if os.isfile(path.join(dir, "SDL_version.h")) then
                        table.insert(configs, "-DSDL2_INCLUDE_DIR=" .. dir)
                        break
                    end
                end
                for _, libfile in ipairs(fetchinfo.libfiles) do
                    if libfile:match("SDL2%..+$") or libfile:match("SDL2-static%..+$") then
                        table.insert(configs, "-DSDL2_LIBRARY=" .. table.concat(fetchinfo.libfiles, ";"))
                    end
                end
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("IMG_Init", {includes = "SDL2/SDL_image.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
