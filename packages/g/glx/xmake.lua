package("glx")

    set_homepage("https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/glXIntro.xml")
    set_description("an extension to the X Window System core protocol providing an interface between OpenGL and the X Window System")

    on_fetch(function (package, opt)
        if opt.system then
            if package:is_plat("linux") and package.find_package then
                return package:find_package("GLX", opt) or package:find_package("pkgconfig::glx", opt)
            end
        end
    end)

    if is_plat("linux") then
        add_extsources("apt::libglx-dev")
    end
