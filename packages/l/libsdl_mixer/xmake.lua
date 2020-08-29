package("libsdl_mixer")
    add_deps("libsdl")

    set_homepage("https://www.libsdl.org/projects/SDL_mixer/")
    set_description("Simple DirectMedia Layer mixer audio library")

    if is_plat("windows", "mingw") then
        set_urls("https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-devel-$(version)-VC.zip")
        add_versions("2.0.4", "258788438b7e0c8abb386de01d1d77efe79287d9967ec92fbb3f89175120f0b0")
    else
        set_urls("https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-$(version).zip")
        add_versions("2.0.4", "9affb8c7bf6fbffda0f6906bfb99c0ea50dca9b188ba9e15be90042dc03c5ded")
    end

    add_links("SDL2_mixer")

    on_install("windows", "mingw", function (package)
        local arch = package:arch()
        if package:is_plat("mingw") then
            arch = (arch == "x86_64") and "x64" or "x86"
        end
        local file_name = "include/SDL_mixer.h"
        local content = io.readfile(file_name)

        content = content:gsub("\"SDL_stdinc.h\"", "<SDL2/SDL_stdinc.h>")
        content = content:gsub("\"SDL_rwops.h\"", "<SDL2/SDL_rwops.h>")
        content = content:gsub("\"SDL_audio.h\"", "<SDL2/SDL_audio.h>")
        content = content:gsub("\"SDL_endian.h\"", "<SDL2/SDL_endian.h>")
        content = content:gsub("\"SDL_version.h\"", "<SDL2/SDL_version.h>")
        content = content:gsub("\"begin_code.h\"", "<SDL2/begin_code.h>")
        content = content:gsub("\"close_code.h\"", "<SDL2/close_code.h>")

        io.writefile(file_name, content)
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
        local file_name = path.join(package:installdir("include"), "SDL2", "SDL_mixer.h")
        local content = io.readfile(file_name)

        content = content:gsub("\"SDL_stdinc.h\"", "<SDL2/SDL_stdinc.h>")
        content = content:gsub("\"SDL_rwops.h\"", "<SDL2/SDL_rwops.h>")
        content = content:gsub("\"SDL_audio.h\"", "<SDL2/SDL_audio.h>")
        content = content:gsub("\"SDL_endian.h\"", "<SDL2/SDL_endian.h>")
        content = content:gsub("\"SDL_version.h\"", "<SDL2/SDL_version.h>")
        content = content:gsub("\"begin_code.h\"", "<SDL2/begin_code.h>")
        content = content:gsub("\"close_code.h\"", "<SDL2/close_code.h>")

        io.writefile(file_name, content)
    end)