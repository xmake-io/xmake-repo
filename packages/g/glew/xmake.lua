package("glew")

    set_homepage("http://glew.sourceforge.net/")
    set_description("A cross-platform open-source C/C++ extension loading library.")

    if is_plat("windows") then
        set_urls("https://github.com/nigels-com/glew/releases/download/glew-$(version)/glew-$(version)-win32.zip")
        add_versions("2.1.0", "80cfc88fd295426b49001a9dc521da793f8547ac10aebfc8bdc91ddc06c5566c")
    else
        set_urls("https://github.com/nigels-com/glew/releases/download/glew-$(version)/glew-$(version).zip")
        add_versions("2.1.0", "2700383d4de2455f06114fbaf872684f15529d4bdc5cdea69b5fb0e9aa7763f1")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("glu32", "opengl32")
    else
        add_links("GLEW")
        if is_plat("linux") then
            add_deps("libx11", "xorgproto", "freeglut")
            add_syslinks("GL")
        elseif is_plat("macosx") then
            add_frameworks("OpenGL")
        end
    end

    on_load(function (package)
        package:add("defines", "GLEW_BUILD")
        if package:is_plat("windows", "mingw") then
            package:add("links", "glew32")
        end
    end)

    if is_plat("mingw") then
        add_deps("cmake")
    end

    on_install("windows", function (package)
        os.cp("include", package:installdir())
        if is_arch("x64") then
            os.cp("bin/Release/x64/*.dll", package:installdir("lib"))
            os.cp("lib/Release/x64/*.lib", package:installdir("lib"))
        else
            os.cp("bin/Release/Win32/*.dll", package:installdir("lib"))
            os.cp("lib/Release/Win32/*.lib", package:installdir("lib"))
        end
    end)

    on_install("linux", "macosx", function (package)
        local configs = {"glew.lib." .. (package:config("shared") and "shared" or "static")}
        local cflags  = {}
        for _, dep in ipairs(package:orderdeps()) do
            local fetchinfo = dep:fetch()
            if fetchinfo then
                for _, includedir in ipairs(fetchinfo.includedirs) do
                    table.insert(cflags, "-I" .. includedir)
                end
            end
        end
        if #cflags > 0 then
            table.insert(configs, "CFLAGS.EXTRA=" .. table.concat(cflags, " "))
        end
        import("package.tools.make").build(package, configs)
        os.cp("lib", package:installdir())
        os.cp("include", package:installdir())
    end)

    on_install("mingw", function (package)
        os.cd("build/cmake")
        local configs = {}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs, {buildir = "build"})
        if package:config("shared") then
            os.cp("build/bin/*.dll", package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("glewInit", {includes = "GL/glew.h"}))
    end)
