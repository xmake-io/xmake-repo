package("freeglut")

    set_homepage("http://freeglut.sourceforge.net")
    set_description("A free-software/open-source alternative to the OpenGL Utility Toolkit (GLUT) library.")

    set_urls("https://github.com/dcnieho/FreeGLUT/archive/FG_$(version).zip",
            {version = function (version) return (version:gsub("%.", "_")) end})
    add_versions("3.0.0", "050e09f17630249a7d2787c21691e4b7d7b86957a06b3f3f34fa887b561d8e04")

    if is_plat("linux", "windows") then
        add_deps("cmake")
    end

    if is_plat("linux") then
        add_deps("libx11", "libxi", "libxxf86vm", "libxrandr")
        add_syslinks("GLU", "GL")
    end

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "FREEGLUT_STATIC=1")
        end
        package:add("defines", "FREEGLUT_LIB_PRAGMAS=0")
        package:add("syslinks", "glu32", "opengl32", "gdi32", "winmm", "user32", "advapi32")
    end)

    on_install("linux", "windows", function (package)
        local configs = {"-DFREEGLUT_BUILD_DEMOS=OFF"}
        if package:config("shared") then
            table.insert(configs, "-DFREEGLUT_BUILD_SHARED_LIBS=ON")
            table.insert(configs, "-DFREEGLUT_BUILD_STATIC_LIBS=OFF")
        else
            table.insert(configs, "-DFREEGLUT_BUILD_SHARED_LIBS=OFF")
            table.insert(configs, "-DFREEGLUT_BUILD_STATIC_LIBS=ON")
        end
        if package:is_plat("windows") then
            if package:config("shared") then
                table.insert(configs, "-DCMAKE_C_FLAGS=-DFREEGLUT_LIB_PRAGMAS=0")
            else
                table.insert(configs, "-DCMAKE_C_FLAGS=-DFREEGLUT_LIB_PRAGMAS=0 -DFREEGLUT_STATIC=1")
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("glutInit", {includes = "GL/glut.h"}))
    end)
