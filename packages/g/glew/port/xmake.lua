add_rules("mode.debug", "mode.release")

if is_plat("linux") then
    add_requires("libx11", "xorgproto")
end

target("glew")
    set_kind("$(kind)")
    if is_plat("windows", "mingw") then
        set_basename(is_kind("shared") and "glew32" or "glew32s")
        add_syslinks("glu32", "opengl32")
    elseif is_plat("macosx") then
        add_frameworks("OpenGL")
    elseif is_plat("linux") then
        add_syslinks("GL")
        add_packages("libx11", "xorgproto")
    end
    add_defines("GLEW_NO_GLU", {public = true})
    if is_plat("windows") then
        if is_kind("shared") then
            add_defines("GLEW_BUILD")
        else
            add_defines("GLEW_STATIC", {public = true})
        end
    elseif is_plat("mingw") and not is_kind("shared") then
        add_defines("GLEW_STATIC", {public = true})
    end
    add_files("src/glew.c")
    add_includedirs("include", {public = true})
    add_headerfiles("include/(GL/*.h)")

target("glewinfo")
    set_kind("binary")
    add_deps("glew")
    if is_plat("windows", "mingw") then
        add_syslinks("user32", "gdi32", "glu32", "opengl32")
    elseif is_plat("macosx") then
        add_frameworks("OpenGL")
    elseif is_plat("linux") then
        add_syslinks("GL")
        add_packages("libx11", "xorgproto")
    end
    add_files("src/glewinfo.c")

target("visualinfo")
    set_kind("binary")
    add_deps("glew")
    if is_plat("windows", "mingw") then
        add_syslinks("user32", "gdi32", "glu32", "opengl32")
    elseif is_plat("macosx") then
        add_frameworks("OpenGL")
    elseif is_plat("linux") then
        add_syslinks("GL")
        add_packages("libx11", "xorgproto")
    end
    add_files("src/visualinfo.c")
