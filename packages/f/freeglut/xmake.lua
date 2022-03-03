package("freeglut")

    set_homepage("http://freeglut.sourceforge.net")
    set_description("A free-software/open-source alternative to the OpenGL Utility Toolkit (GLUT) library.")

    set_urls("https://github.com/dcnieho/FreeGLUT/archive/FG_$(version).zip",
            {version = function (version) return (version:gsub("%.", "_")) end})
    add_versions("3.0.0", "050e09f17630249a7d2787c21691e4b7d7b86957a06b3f3f34fa887b561d8e04")
    add_versions("3.2.1", "501324c27a3ee809ac4a6374f63c5049c1c0d342d93fdb5db12b8c1c84760fa4")

    add_patches("3.2.1", path.join(os.scriptdir(), "patches", "3.2.1", "gcc10.patch"), "26cf5026249c9e288080a75a1e9b40b3fa74a4048321cc93907f1476c5a6508b")

    if is_plat("linux", "windows") then
        add_deps("cmake")
    end

    if is_plat("linux") then
        add_deps("libx11", "libxi", "libxxf86vm", "libxrandr", "libxrender")
        add_deps("glx", {optional = true})
    end
    add_deps("glu", "opengl", {optional = true})

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "FREEGLUT_STATIC=1")
        end
        package:add("defines", "FREEGLUT_LIB_PRAGMAS=0")
        package:add("syslinks", "gdi32", "winmm", "user32", "advapi32")
    end)

    on_fetch("linux", function (package, opt)
        if package.find_package then
            return package:find_package("pkgconfig::glut", opt)
        end
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
        if package:is_plat("linux") then
            import("package.tools.cmake").install(package, configs, {packagedeps = {"libxi", "libxxf86vm", "libxrandr", "libxrender"}})
        else
            import("package.tools.cmake").install(package, configs)
        end
        os.trycp(path.join("include", "GL", "glut.h"), package:installdir("include", "GL"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("glutInit", {includes = "GL/glut.h"}))
    end)
