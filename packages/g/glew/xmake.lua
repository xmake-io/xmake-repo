package("glew")

    set_homepage("http://glew.sourceforge.net/")
    set_description("A cross-platform open-source C/C++ extension loading library.")

    set_urls("https://github.com/nigels-com/glew/releases/download/glew-$(version)/glew-$(version).zip")
    add_versions("2.1.0", "2700383d4de2455f06114fbaf872684f15529d4bdc5cdea69b5fb0e9aa7763f1")
    add_versions("2.2.0", "a9046a913774395a095edcc0b0ac2d81c3aacca61787b39839b941e9be14e0d4")

    add_defines("GLEW_NO_GLU")

    on_load(function (package)
        package:add("deps", "opengl")
        if package:is_plat("linux") then
            package:add("syslinks", "GL")
            package:add("deps", "libx11", "xorgproto")
        elseif package:is_plat("windows", "mingw") then
            package:add("syslinks", "opengl32")
            if not package:config("shared") then
                package:add("defines", "GLEW_STATIC")
            end
        end
    end)

    on_install("linux", "macosx", "mingw", "windows", function (package)
        local configs = {vers = package:version_str()}
        configs.mode = package:debug() and "debug" or "release"
        if package:config("shared") then
            configs.kind = "shared"
        elseif package:is_plat("linux") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("glewInit", {includes = "GL/glew.h"}))
    end)
