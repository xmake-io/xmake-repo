package("haclog")
    set_homepage("https://github.com/MuggleWei/haclog")
    set_description("Haclog(Happy Aync C log) is an extremely fast plain C logging library")
    set_license("MIT")

    add_urls("https://github.com/MuggleWei/haclog/archive/refs/tags/$(version).tar.gz",
             "https://github.com/MuggleWei/haclog.git")

    add_versions("v0.4.0", "00752913e253acc2dbd7408d03a1a02893ca36542a20e8b88e8e2dc3d68fcd3d")
    add_versions("v0.2.0", "5e055f69e490298a9515c38b3b024a97b41d4dfb5daaaf0ef94eb5c1da9db5ca")
    add_versions("v0.1.6", "3afdb52d21b03a085291074612c39fab3ef056b6b32071693df4a2b60b9b6554")
    add_versions("v0.0.5", "789340ba87ac076e4c5559e1e6e0bf4f1e17f2e55c4845d0f9fc8ead8e6d7f5f")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:is_plat("cross") then
            package:add("deps", "meson", "ninja")
        else
            package:add("deps", "cmake")
        end
    end)

    on_install("windows", "linux", "macosx", "android", "cross", function (package)
        local configs = {}
        if package:is_plat("cross") then
            table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
            import("package.tools.meson").install(package, configs)
        else
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("haclog_console_handler_init", {includes = "haclog/haclog.h"}))
    end)
