package("libsdl3_image")
    set_homepage("https://github.com/libsdl-org/SDL_image")
    set_description("Image decoding for many popular formats for Simple Directmedia Layer.")
    set_license("zlib")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::sdl3-image")
    elseif is_plat("linux") then
        add_extsources("apt::libsdl3-image-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl3_image")
    end

    add_urls("https://www.libsdl.org/projects/SDL_image/release/SDL3_image-$(version).zip",
             "https://github.com/libsdl-org/SDL_image/releases/download/release-$(version)/SDL3_image-$(version).zip", { alias = "archive" })
    add_urls("https://github.com/libsdl-org/SDL_image", { alias = "github" })

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
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("IMG_Version", {includes = "SDL3_image/SDL_image.h"}))
    end)
