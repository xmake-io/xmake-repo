package("libsdl_ttf")
    add_deps("libsdl")

    set_homepage("https://www.libsdl.org/projects/SDL_ttf/")
    set_description("Simple DirectMedia Layer text rendering library")

    if is_plat("windows", "mingw") then
        set_urls("https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-devel-$(version)-VC.zip")
        add_versions("2.0.15", "aab0d81f1aa6fe654be412efc85829f2b188165dca6c90eb4b12b673f93e054b")
    -- else
    --     set_urls("https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-$(version).zip")
    --     add_versions("2.0.15", "cdb72b5b1c3b27795fa128af36f369fee5d3e38a96c350855da0b81880555dbc")
    end

    add_links("SDL2_ttf")

    on_install("windows", "mingw", function (package)
        local arch = package:arch()
        if package:is_plat("mingw") then
            arch = (arch == "x86_64") and "x64" or "x86"
        end
        local file_name = "include/SDL_ttf.h"
        local f = io.open(file_name)
        local content = f:read("*all")
        f:close()

        content = string.gsub(content, "\"SDL.h\"", "<SDL2/SDL.h>")
        content = string.gsub(content, "\"begin_code.h\"", "<SDL2/begin_code.h>")
        content = string.gsub(content, "\"close_code.h\"", "<SDL2/close_code.h>")

        local f = io.open(file_name, "w")
        f:write(content)
        f:close()
        os.cp("include/*", package:installdir("include/SDL2"))
        os.cp(path.join("lib", arch, "*.lib"), package:installdir("lib"))
        os.cp(path.join("lib", arch, "*.dll"), package:installdir("lib"))
    end)

    -- on_install("macosx", "linux", function (package)
    --     local configs = {}
    --     if package:config("shared") then
    --         table.insert(configs, "--enable-shared=yes")
    --     else
    --         table.insert(configs, "--enable-shared=no")
    --     end
    --     import("package.tools.autoconf").install(package, configs)
    --     local file_name = path.join(package:installdir("include"), "SDL2", "SDL_ttf.h")
    --     local f = io.open(file_name)
    --     local content = f:read("*all")
    --     f:close()

    --     content = string.gsub(content, "\"SDL.h\"", "<SDL2/SDL.h>")
    --     content = string.gsub(content, "\"begin_code.h\"", "<SDL2/begin_code.h>")
    --     content = string.gsub(content, "\"close_code.h\"", "<SDL2/close_code.h>")

    --     local f = io.open(file_name, "w")
    --     f:write(content)
    --     f:close()
    -- end)