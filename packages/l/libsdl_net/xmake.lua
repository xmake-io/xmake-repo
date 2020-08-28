package("libsdl_net")
    add_deps("libsdl")

    set_homepage("https://www.libsdl.org/projects/SDL_net/")
    set_description("Simple DirectMedia Layer networking library")

    if is_plat("windows", "mingw") then
        set_urls("https://www.libsdl.org/projects/SDL_net/release/SDL2_net-devel-$(version)-VC.zip")
        add_versions("2.0.1", "c1e423f2068adc6ff1070fa3d6a7886700200538b78fd5adc36903a5311a243e")
    else
        set_urls("https://www.libsdl.org/projects/SDL_net/release/SDL2_net-$(version).zip")
        add_versions("2.0.1", "52031ed9d08a5eb1eda40e9a0409248bf532dde5e8babff5780ef1925657d59f")
    end

    add_links("SDL2_net")

    on_install("windows", "mingw", function (package)
        local arch = package:arch()
        if package:is_plat("mingw") then
            arch = (arch == "x86_64") and "x64" or "x86"
        end
        local file_name = "include/SDL_net.h"
        local f = io.open(file_name)
        local content = f:read("*all")
        f:close()

        content = string.gsub(content, "\"SDL.h\"", "<SDL2/SDL.h>")
        content = string.gsub(content, "\"SDL_version.h\"", "<SDL2/SDL_version.h>")
        content = string.gsub(content, "\"SDL_endian.h\"", "<SDL2/SDL_endian.h>")
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
        local file_name = path.join(package:installdir("include"), "SDL2", "SDL_net.h")
        local f = io.open(file_name)
        local content = f:read("*all")
        f:close()

        content = string.gsub(content, "\"SDL.h\"", "<SDL2/SDL.h>")
        content = string.gsub(content, "\"SDL_version.h\"", "<SDL2/SDL_version.h>")
        content = string.gsub(content, "\"SDL_endian.h\"", "<SDL2/SDL_endian.h>")
        content = string.gsub(content, "\"begin_code.h\"", "<SDL2/begin_code.h>")
        content = string.gsub(content, "\"close_code.h\"", "<SDL2/close_code.h>")

        local f = io.open(file_name, "w")
        f:write(content)
        f:close()
    end)