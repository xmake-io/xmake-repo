package("glew")

    set_homepage("http://glew.sourceforge.net/")
    set_description("A cross-platform open-source C/C++ extension loading library.")

    set_urls("https://github.com/nigels-com/glew/releases/download/glew-$(version)/glew-$(version).zip")
    add_versions("2.1.0", "2700383d4de2455f06114fbaf872684f15529d4bdc5cdea69b5fb0e9aa7763f1")
    add_versions("2.2.0", "a9046a913774395a095edcc0b0ac2d81c3aacca61787b39839b941e9be14e0d4")

    if is_plat("windows") or is_plat("mingw") then
        add_syslinks("opengl32")
    elseif is_plat("linux") then
        add_syslinks("GL")
        add_deps("libx11", "xorgproto")
    end
    add_defines("GLEW_NO_GLU")

    on_load("windows", "mingw", function (package)
        if not package:config("shared") then
            package:add("defines", "GLEW_STATIC")
        end
    end)

    on_install("linux", "macosx", "mingw", "windows", function (package)
        local configs = {}
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
