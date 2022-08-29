package("libsdl_ttf")

    set_homepage("https://www.libsdl.org/projects/SDL_ttf/")
    set_description("Simple DirectMedia Layer text rendering library")
    set_license("zlib")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::SDL2_ttf")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl2_ttf", "apt::libsdl2-ttf-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl2_ttf")
    end

    if is_plat("windows", "mingw") then
        set_urls("https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-devel-$(version)-VC.zip")
        add_urls("https://github.com/libsdl-org/SDL_ttf/releases/download/release-$(version)/SDL2_ttf-devel-$(version)-VC.zip")
        add_versions("2.0.15", "aab0d81f1aa6fe654be412efc85829f2b188165dca6c90eb4b12b673f93e054b")
        add_versions("2.0.18", "4e1404ac6095bbcd4cb133eb644a765885aa283ae45f36cfbc3cf5a77d7e1cbd")
        add_versions("2.20.0", "bc206392a74d2b32f74d770a3a1e623e87c72374781c115478277ab4c722358b")
        add_versions("2.20.1", "2facfa180f77bac381776376c7598ad504a84d99414418049bb106cb1705fe22")
    else
        set_urls("https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-$(version).zip")
        add_urls("https://github.com/libsdl-org/SDL_ttf/releases/download/release-$(version)/SDL2_ttf-$(version).zip")
        add_versions("2.0.15", "cdb72b5b1c3b27795fa128af36f369fee5d3e38a96c350855da0b81880555dbc")
        add_versions("2.0.18", "64e6a93c7542aba1e32e1418413898dfde82be95fdd0c73ba265fbdada189b5f")
        add_versions("2.20.0", "04e94fc5ecac3475ab35c1d5cf52650df691867e7e4befcc861bf982a747111a")
        add_versions("2.20.1", "18d81ab399c8e39adababe8918691830ba6e0d6448e5baa141ee0ddf87ede2dc")
    end

    add_deps("libsdl")
    if is_plat("linux", "macosx") then
        add_deps("automake", "autoconf", "freetype")
    end

    add_links("SDL2_ttf")
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
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:is_plat("linux") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        local libsdl = package:dep("libsdl")
        if libsdl and not libsdl:is_system() then
            table.insert(configs, "--with-sdl-prefix=" .. libsdl:installdir())
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("TTF_Init", {includes = "SDL2/SDL_ttf.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
