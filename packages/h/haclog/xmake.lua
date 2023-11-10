package("haclog")
    set_homepage("https://github.com/MuggleWei/haclog")
    set_description("Haclog(Happy Aync C log) is an extremely fast plain C logging library")
    set_license("MIT")

    add_urls("https://github.com/MuggleWei/haclog/archive/refs/tags/$(version).tar.gz",
             "https://github.com/MuggleWei/haclog.git")

    add_versions("v0.0.5", "789340ba87ac076e4c5559e1e6e0bf4f1e17f2e55c4845d0f9fc8ead8e6d7f5f")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install("windows", "linux", "macosx", "android", "cross", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("haclog_console_handler_init", {includes = "haclog/haclog.h"}))
    end)
