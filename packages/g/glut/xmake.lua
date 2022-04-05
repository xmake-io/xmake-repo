package("glut")

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
        else
            local freeglut = package:dep("freeglut")
            if freeglut then
                return freeglut:fetch(opt)
            end
        end
    end)
