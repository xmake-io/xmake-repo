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

    if is_plat("windows", "mingw") then
        set_urls("https://www.libsdl.org/projects/SDL_image/release/SDL2_image-devel-$(version)-VC.zip")
        add_urls("https://github.com/libsdl-org/SDL_image/releases/download/release-$(version)/SDL2_image-devel-$(version)-VC.zip")
        add_versions("2.0.5", "a180f9b75c4d3fbafe02af42c42463cc7bc488e763cfd1ec2ffb75678b4387ac")
        add_versions("2.6.0", "e8953ec28e689fdef7805d0dc6913b8038dc6e250fe340929e459f367e2e75fa")
        add_versions("2.6.1", "b431347d039081b3ec065670d3037f106c8683f11491c45776cde7e69965a5f3")
        add_versions("2.6.2", "f510a58b03ce2b74a68d4e6733c47c1931813ab1736e533ad576f4cecb3a8a4d")
    else
        set_urls("https://www.libsdl.org/projects/SDL_image/release/SDL2_image-$(version).zip")
        add_urls("https://github.com/libsdl-org/SDL_image/releases/download/release-$(version)/SDL2_image-$(version).zip")
        add_versions("2.0.5", "eee0927d1e7819d57c623fe3e2b3c6761c77c474fe9bc425e8674d30ac049b1c")
        add_versions("2.6.0", "2252cdfd5be73cefaf727edc39c2ef3b7682e797acbd3126df117e925d46aaf6")
        add_versions("2.6.1", "cbfea63a46715c63a1db9e41617e550749a95ffd33ef9bd5ba6e58b2bdca6ed3")
        add_versions("2.6.2", "efe3c229853d0d40c35e5a34c3f532d5d9728f0abc623bc62c962bcef8754205")
    end

    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreGraphics", "ImageIO", "CoreServices")
    end

    if is_plat("macosx", "linux") then
        add_deps("automake", "autoconf")
    end
    add_deps("libsdl")

    add_links("SDL2_image")
    add_includedirs("include", "include/SDL2")

    on_load(function (package)
        if package:version():ge("2.6") and package:is_plat("macosx", "linux") then
            package:add("deps", "cmake")
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

    on_install("macosx", "linux", function (package)
        if package:version():ge("2.6") then
            local configs = {"-DSDL_TEST=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
            table.insert(configs, "-DSDL_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
            table.insert(configs, "-DSDL_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
            if libsdl and not libsdl:is_system() then
                table.insert(configs, "-DSDL2_DIR=" .. libsdl:installdir())
            end
            import("package.tools.cmake").install(package, configs)
        else
            local configs = {}
            table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
            table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
            local libsdl = package:dep("libsdl")
            if libsdl and not libsdl:is_system() then
                table.insert(configs, "--with-sdl-prefix=" .. libsdl:installdir())
            end
            io.replace("Makefile.am", "noinst_PROGRAMS = showimage.-\n", "\n")
            os.rm("./configure")
            import("package.tools.autoconf").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("IMG_Init", {includes = "SDL2/SDL_image.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
