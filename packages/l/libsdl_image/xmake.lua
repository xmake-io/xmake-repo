package("libsdl_image")
    add_deps("libsdl")

    set_homepage("http://www.libsdl.org/projects/SDL_image/")
    set_description("Simple DirectMedia Layer image loading library")

    if is_plat("windows", "mingw") then
        set_urls("https://www.libsdl.org/projects/SDL_image/release/SDL2_image-devel-$(version)-VC.zip")
        add_versions("2.0.5", "a180f9b75c4d3fbafe02af42c42463cc7bc488e763cfd1ec2ffb75678b4387ac")
    else
        set_urls("https://www.libsdl.org/projects/SDL_image/release/SDL2_image-$(version).zip")
        add_versions("2.0.5", "eee0927d1e7819d57c623fe3e2b3c6761c77c474fe9bc425e8674d30ac049b1c")
    end

    add_links("SDL2_image")

    on_install("windows", "mingw", function (package)
        local arch = package:arch()
        if package:is_plat("mingw") then
            arch = (arch == "x86_64") and "x64" or "x86"
        end
        local file_name = "include/SDL_image.h"
        local f = io.open(file_name)
        local content = f:read("*all")
        f:close()

        content = string.gsub(content, "\"SDL.h\"", "<SDL2/SDL.h>")
        content = string.gsub(content, "\"SDL_version.h\"", "<SDL2/SDL_version.h>")
        content = string.gsub(content, "\"begin_code.h\"", "<SDL2/begin_code.h>")
        content = string.gsub(content, "\"close_code.h\"", "<SDL2/close_code.h>")

        local f = io.open(file_name, "w")
        f:write(content)
        f:close()
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
        local file_name = path.join(package:installdir("include"), "SDL2", "SDL_image.h")
        local f = io.open(file_name)
        local content = f:read("*all")
        f:close()

        content = string.gsub(content, "\"SDL.h\"", "<SDL2/SDL.h>")
        content = string.gsub(content, "\"SDL_version.h\"", "<SDL2/SDL_version.h>")
        content = string.gsub(content, "\"begin_code.h\"", "<SDL2/begin_code.h>")
        content = string.gsub(content, "\"close_code.h\"", "<SDL2/close_code.h>")

        local f = io.open(file_name, "w")
        f:write(content)
        f:close()
    end)