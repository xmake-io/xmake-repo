package("gl2ps")
    set_homepage("https://gitlab.onelab.info/gl2ps/gl2ps")
    set_description("OpenGL to PostScript printing library")
    set_license("LGPL")

    add_urls("https://gitlab.onelab.info/gl2ps/gl2ps/-/archive/gl2ps_$(version)/gl2ps-gl2ps_$(version).tar.gz",
             "https://gitlab.onelab.info/gl2ps/gl2ps.git", { version = function(version)
        return version:gsub("%.", "_")
    end})

    add_versions("1.4.2", "469313d28bd22bcbf7b7ea300dddb9b6c13854455d297f4d51a944e378b0a9d7")

    add_configs("zlib", {description = "Enable compression using ZLIB", default = true, type = "boolean"})
    add_configs("png", {description = "Enable PNG support", default = true, type = "boolean"})

    add_deps("freeglut", "opengl")

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    elseif is_plat("macosx") then
        add_frameworks("Cocoa", "OpenGL")
    end

    on_load(function (package)
        if package:config("zlib") then
            package:add("deps", "zlib")
        end
        if package:config("png") then
            package:add("deps", "libpng")
        end
    end)

    on_install(function (package)
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
