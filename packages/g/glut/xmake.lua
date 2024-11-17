package("glut")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.opengl.org/resources/libraries/glut/")
    set_description("OpenGL utility toolkit")

    if not is_plat("macosx") then
        add_deps("freeglut")
    end

    on_fetch(function (package, opt)
        if opt.system then
            if package:is_plat("macosx") then
                return {frameworks = {"GLUT", "OpenGL"}, defines = "GL_SILENCE_DEPRECATION"}
            end
        end
    end)

    on_install("windows", "mingw", "macosx", "linux", function (package)
        -- do nothing, only to keep dep available
    end)
