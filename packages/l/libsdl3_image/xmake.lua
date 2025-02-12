package("libsdl3_image")
    set_homepage("http://www.libsdl.org/projects/SDL_image/")
    set_description("Simple DirectMedia Layer image loading library")
    set_license("zlib")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::SDL3_image")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl3_image", "apt::libsdl3-image-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl3_image")
    end

    add_urls("https://www.libsdl.org/projects/SDL_image/release/SDL3_image-$(version).zip",
             "https://github.com/libsdl-org/SDL_image/releases/download/release-$(version)/SDL3_image-$(version).zip", { alias = "archive" })
    add_urls("https://github.com/libsdl-org/SDL_image", { alias = "github" })
    add_versions("3.2.0", "144715a6afae430adc275fd3ab0e3e96177a2752cc10a49ca78511b1e665964e")

    add_versions("archive:3.2.0", "144715a6afae430adc275fd3ab0e3e96177a2752cc10a49ca78511b1e665964e")

    add_versions("github:3.2.0", "release-3.2.0")

    if is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation", "CoreGraphics", "ImageIO", "CoreServices")
    end

    add_deps("cmake")

    on_load(function (package)
        package:add("deps", "libsdl3", { configs = { shared = package:config("shared") }})
    end)

    on_install(function (package)
        local configs = {"-DSDLIMAGE_SAMPLES=OFF", "-DSDLIMAGE_TESTS=OFF", "-DSDLIMAGE_VENDORED=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        local libsdl3 = package:dep("libsdl3")
        if libsdl3 and not libsdl3:is_system() then
            table.insert(configs, "-DSDL3_DIR=" .. libsdl3:installdir())
            local fetchinfo = libsdl3:fetch()
            if fetchinfo then
                for _, dir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    if os.isfile(path.join(dir, "SDL_version.h")) then
                        table.insert(configs, "-DSDL3_INCLUDE_DIR=" .. dir)
                        break
                    end
                end
                local libfiles = {}
                for _, libfile in ipairs(fetchinfo.libfiles) do
                    if libfile:match("SDL3%..+$") or libfile:match("SDL3-static%..+$") then
                        if not (package:config("shared") and libfile:endswith(".dll")) then
                            table.insert(libfiles, libfile)
                        end
                    end
                end
                table.insert(configs, "-DSDL3_LIBRARY=" .. table.concat(libfiles, ";"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("IMG_Version", {includes = "SDL3_image/SDL_image.h"}))
    end)
