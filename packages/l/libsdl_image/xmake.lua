package("libsdl_image")

    set_homepage("http://www.libsdl.org/projects/SDL_image/")
    set_description("Simple DirectMedia Layer image loading library")

    if is_plat("windows", "mingw") then
        set_urls("https://www.libsdl.org/projects/SDL_image/release/SDL2_image-devel-$(version)-VC.zip")
        add_versions("2.0.5", "a180f9b75c4d3fbafe02af42c42463cc7bc488e763cfd1ec2ffb75678b4387ac")
    else
        set_urls("https://www.libsdl.org/projects/SDL_image/release/SDL2_image-$(version).zip")
        add_versions("2.0.5", "eee0927d1e7819d57c623fe3e2b3c6761c77c474fe9bc425e8674d30ac049b1c")
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::SDL2_image")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl2_image", "apt::libsdl2-image-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl2_image")
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
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-shared=no")
        end
        if package:is_plat("linux") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        local libsdl = package:dep("libsdl")
        if libsdl and not libsdl:is_system() then
            table.insert(configs, "--with-sdl-prefix=" .. libsdl:installdir())
        end
        io.replace("Makefile.am", "noinst_PROGRAMS = showimage", "")
        os.rm("./configure")
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("IMG_Init", {includes = "SDL2/SDL_image.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
