package("libsdl")

    set_homepage("https://www.libsdl.org/")
    set_description("Simple DirectMedia Layer")

    if is_plat("windows", "mingw") then
        set_urls("https://www.libsdl.org/release/SDL2-devel-$(version)-VC.zip")
        add_versions("2.0.8", "68505e1f7c16d8538e116405411205355a029dcf2df738dbbc768b2fe95d20fd")
        add_versions("2.0.12", "00c55a597cebdb9a4eb2723f2ad2387a4d7fd605e222c69b46099b15d5d8b32d")
        add_versions("2.0.14", "232071cf7d40546cde9daeddd0ec30e8a13254c3431be1f60e1cdab35a968824")
    else
        set_urls("https://www.libsdl.org/release/SDL2-$(version).zip")
        add_versions("2.0.8", "e6a7c71154c3001e318ba7ed4b98582de72ff970aca05abc9f45f7cbdc9088cb")
        add_versions("2.0.12", "476e84d6fcbc499cd1f4a2d3fd05a924abc165b5d0e0d53522c9604fe5a021aa")
        add_versions("2.0.14", "2c1e870d74e13dfdae870600bfcb6862a5eab4ea5b915144aff8d75a0f9bf046")
    end

    if is_plat("macosx") then
        add_frameworks("OpenGL", "CoreVideo", "CoreAudio", "AudioToolbox", "Carbon", "CoreGraphics", "ForceFeedback", "Metal", "AppKit", "IOKit", "CoreFoundation", "Foundation")
        add_syslinks("iconv")
    elseif is_plat("linux") then
        add_syslinks("pthread", "dl")
    elseif is_plat("windows", "mingw") then
        add_syslinks("gdi32", "user32", "winmm", "shell32")
    end
    add_links("SDL2main", "SDL2")
    add_includedirs("include", "include/SDL2")

    on_install("windows", "mingw", function (package)
        local arch = package:arch()
        if package:is_plat("mingw") then
            arch = (arch == "x86_64") and "x64" or "x86"
        end
        os.cp("include/*", package:installdir("include/SDL2"))
        os.cp(path.join("lib", arch, "*.lib"), package:installdir("lib"))
        os.cp(path.join("lib", arch, "*.dll"), package:installdir("lib"))
    end)

    on_install("macosx", "linux", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-shared=no")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SDL_Init", {includes = "SDL2/SDL.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
