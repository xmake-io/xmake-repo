package("gl2ps")
    set_homepage("https://gitlab.onelab.info/gl2ps/gl2ps")
    set_description("OpenGL to PostScript printing library")
    set_license("LGPL")

    add_urls("https://gitlab.onelab.info/gl2ps/gl2ps/-/archive/gl2ps_$(version)/gl2ps-gl2ps_$(version).tar.gz",
             "https://gitlab.onelab.info/gl2ps/gl2ps.git", { version = function(version)
        return version:gsub("%.", "_")
    end})

    add_versions("1.4.2", "afb6f4a8df9c7639449546a79aabd1baaccacc4360fc23741c6485138512ff72")

    add_configs("zlib", {description = "Enable compression using ZLIB", default = true, type = "boolean"})
    add_configs("png", {description = "Enable PNG support", default = true, type = "boolean"})

    add_deps("opengl")

    if is_plat("linux", "windows", "mingw")
        add_deps("freeglut")
    else
        add_deps("glut")
    end

    if is_plat("macosx", "linux", "bsd") then
        add_deps("libx11", "libxext")
    end

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    elseif is_plat("macosx") then
        add_frameworks("Cocoa", "OpenGL")
    end

    on_check("windows", function (package)
        local msvc = package:toolchain("msvc")
        if msvc and package:is_arch("arm.*") then
            local vs = msvc:config("vs")
            assert(vs and tonumber(vs) >= 2022, "package(gl2ps): requires Visual Studio 2022 and later for arm targets")
        end
    end)

    on_load(function (package)
        if package:config("zlib") then
            package:add("deps", "zlib")
        end
        if package:config("png") then
            package:add("deps", "libpng")
        end
    end)

    on_install("!wasm", function (package)
        io.replace("CMakeLists.txt", "if(GLUT_FOUND)", "if(0)", {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_ZLIB=" .. (package:config("zlib") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_PNG=" .. (package:config("png") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gl2psEndPage", {includes = "gl2ps.h"}))
    end)
