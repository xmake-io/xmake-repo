package("freeglut")
    set_homepage("http://freeglut.sourceforge.net")
    set_description("Free implementation of the OpenGL Utility Toolkit (GLUT)")
    set_license("MIT")

    add_urls("https://github.com/freeglut/freeglut/releases/download/v$(version)/freeglut-$(version).tar.gz",
             "https://github.com/freeglut/freeglut.git")

    add_versions("3.8.0", "674dcaff25010e09e450aec458b8870d9e98c46f99538db457ab659b321d9989")
    add_versions("3.6.0", "9c3d4d6516fbfa0280edc93c77698fb7303e443c1aaaf37d269e3288a6c3ea52")
    add_versions("3.4.0", "3c0bcb915d9b180a97edaebd011b7a1de54583a838644dcd42bb0ea0c6f3eaec")

    add_patches("3.4.0", "patches/3.4.0/arm64.patch", "a96b538e218ca478c7678aad62b724226dcdf11371da58d1287b95dbe241d00e")
    add_patches("3.6.0", "https://github.com/freeglut/freeglut/commit/800772e993a3ceffa01ccf3fca449d3279cde338.patch", "3c5fd7c50882c721f8db1a97d766db3b17ac79db92eeb00c820ffe9139a1544c")

    add_deps("cmake")

    if is_plat("linux") then
        add_deps("libx11", "libxi", "libxxf86vm", "libxrandr", "libxrender")
        add_deps("glx", {optional = true})
    end
    add_deps("glu", "opengl", {optional = true})

    if on_check then
        on_check("windows", function (package)
            local msvc = package:toolchain("msvc")
            if msvc and package:is_arch("arm.*") then
                local vs = msvc:config("vs")
                assert(vs and tonumber(vs) >= 2022, "package(freeglut): requires Visual Studio 2022 and later for arm targets")
            end
        end)
    end

    on_load("windows", "mingw", function (package)
        if not package:config("shared") then
            package:add("defines", "FREEGLUT_STATIC")
        end
        package:add("defines", "FREEGLUT_LIB_PRAGMAS=0")
        package:add("syslinks", "gdi32", "winmm", "user32", "advapi32")
    end)

    on_fetch("linux", function (package, opt)
        if package.find_package then
            return package:find_package("pkgconfig::glut", opt)
        end
    end)

    on_install("linux", "windows", "mingw", function (package)
        local configs = {"-DFREEGLUT_BUILD_DEMOS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DFREEGLUT_BUILD_SHARED_LIBS=ON")
            table.insert(configs, "-DFREEGLUT_BUILD_STATIC_LIBS=OFF")
        else
            table.insert(configs, "-DFREEGLUT_BUILD_SHARED_LIBS=OFF")
            table.insert(configs, "-DFREEGLUT_BUILD_STATIC_LIBS=ON")
        end

        local opt = {}
        opt.cxflags = {}
        if package:is_plat("windows") then
            if package:config("shared") then
                table.insert(opt.cxflags, "-DFREEGLUT_LIB_PRAGMAS=0")
            else
                table.insert(opt.cxflags, "-DFREEGLUT_LIB_PRAGMAS=0")
                table.insert(opt.cxflags, "-DFREEGLUT_STATIC")
            end
            if package:is_arch("arm64") then
                local vs = package:toolchain("msvc"):config("vs")
                if vs then
                    assert(tonumber(vs) >= 2022, "package(freeglut): requires Visual Studio 2022 and later for arm targets")
                    table.insert(configs, "-DCMAKE_SYSTEM_NAME=Windows")
                    table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=ARM64")
                end
            end
        end
        if package:is_plat("linux") then
            opt.packagedeps = {"libxi", "libxxf86vm", "libxrandr", "libxrender"}
        end

        import("package.tools.cmake").install(package, configs, opt)
        os.trycp(path.join("include", "GL", "glut.h"), package:installdir("include", "GL"))
        if package:is_plat("windows") and not package:config("shared") then
            os.trycp(path.join(package:installdir("lib"), "freeglut_static.lib"), path.join(package:installdir("lib"), "freeglut.lib"))
            package:add("links", "freeglut")
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("glutInit", {includes = "GL/glut.h"}))
    end)
