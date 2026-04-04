add_rules("mode.debug", "mode.release")

option("vers", {description = "Set the version"})

if is_plat("linux") then
    add_requires("libx11", "xorgproto")
end

target("glew")
    set_version("$(vers)")
    add_rules("utils.install.cmake_importfiles")
    add_rules("utils.install.pkgconfig_importfiles")
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
    -- pkgconfig_importfiles names the .pc after target:basename() which on Windows is
    -- "glew32" or "glew32s", not "glew". Generate glew.pc manually so pkg_check_modules
    -- can find it, and include -DGLEW_STATIC in Cflags for static builds.
    if is_plat("windows", "mingw") then
        after_install(function (target)
            local installdir = path.unix(target:installdir())
            local pcdir = path.join(target:installdir(), "lib", "pkgconfig")
            os.mkdir(pcdir)
            local file = io.open(path.join(pcdir, "glew.pc"), "w")
            if file then
                file:print("prefix=%s", installdir)
                file:print("exec_prefix=${prefix}")
                file:print("libdir=${prefix}/lib")
                file:print("includedir=${prefix}/include")
                file:print("")
                file:print("Name: glew")
                file:print("Description: The OpenGL Extension Wrangler Library")
                file:print("Version: %s", target:get("version") or "")
                file:print("Libs: -L${libdir} -l%s", target:basename())
                local cflags = "-I${includedir}"
                if not target:is_shared() then
                    cflags = cflags .. " -DGLEW_STATIC"
                end
                file:print("Cflags: %s", cflags)
                file:close()
            end
        end)
    end

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
