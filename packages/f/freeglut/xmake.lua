package("freeglut")

    set_homepage("http://freeglut.sourceforge.net")
    set_description("A free-software/open-source alternative to the OpenGL Utility Toolkit (GLUT) library.")
    set_license("MIT")

    add_urls("https://github.com/FreeGLUTProject/freeglut/archive/refs/tags/$(version).zip",
             "https://github.com/FreeGLUTProject/freeglut.git")
    add_versions("v3.4.0", "8aed768c71dd5ec0676216bc25e23fa928cc628c82e54ecca261385ccfcee93a")

    add_patches("v3.4.0", path.join(os.scriptdir(), "patches", "3.4.0", "arm64.patch"), "a96b538e218ca478c7678aad62b724226dcdf11371da58d1287b95dbe241d00e")

    add_deps("cmake")

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
            if package:is_arch("arm64") then
                local vs = import("core.tool.toolchain").load("msvc"):config("vs")
                assert(tonumber(vs) >= 2022, "freeglut requires Visual Studio 2022 and later for arm targets")
                table.insert(configs, "-DCMAKE_SYSTEM_NAME=Windows")
                table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=ARM64")
            end
        end
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
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
