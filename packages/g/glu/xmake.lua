package("glu")

    set_homepage("https://gitlab.freedesktop.org/mesa/glu")
    set_description("OpenGL utility library")

    on_fetch(function (package, opt)
        if package:is_plat("macosx") then
            return {frameworks = "OpenGL", defines = "GL_SILENCE_DEPRECATION"}
        elseif package:is_plat("windows", "mingw") then
            return {links = "glu32"}
        end
        if opt.system then
            if package:is_plat("linux") and package.find_package then
                return package:find_package("glu", opt) or package:find_package("libglu", opt)
            end
        end
    end)
