package("libxslt")
    set_homepage("http://xmlsoft.org/XSLT/")
    set_description("Libxslt is the XSLT C library developed for the GNOME project.")
    set_license("MIT")

    add_urls("https://gitlab.gnome.org/GNOME/libxslt/-/archive/$(version)/libxslt-$(version).tar.bz2",
             "https://gitlab.gnome.org/GNOME/libxslt.git")

    add_versions("v1.1.42", "1df3134451708a0098850f9b9e8d86734af7a08f5bea5890f7a3e02b9ccd59d9")

    add_configs("crypto", {description = "Add crypto support to exslt", default = false, type = "boolean"})
    add_configs("moudles", {description = "Add plugin extension support", default = false, type = "boolean"})
    add_configs("thread", {description = "Add multithread support", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("libxml2")

    on_load(function (package)
        if package:config("crypto") then
            package:add("deps", "libgcrypt")
        end
        if package:config("thread") and package:is_plat("linux", "bsd") then
            package:add("syslinks", "pthread")
        end
        if package:is_plat("windows", "mingw") and not package:config("shared") then
            package:add("defines", "LIBXSLT_STATIC")
        end
    end)

    on_install("!iphoneos", function (package)
        local configs = {"-DLIBXSLT_WITH_TESTS=OFF", "-DLIBXSLT_WITH_PYTHON=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DLIBXSLT_WITH_DEBUGGER=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DLIBXSLT_WITH_XSLT_DEBUG=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DLIBXSLT_WITH_CRYPTO=" .. (package:config("crypto") and "ON" or "OFF"))
        table.insert(configs, "-DLIBXSLT_WITH_MODULES=" .. (package:config("moudles") and "ON" or "OFF"))
        table.insert(configs, "-DLIBXSLT_WITH_THREADS=" .. (package:config("thread") and "ON" or "OFF"))
        table.insert(configs, "-DLIBXSLT_WITH_PROGRAMS=" .. (package:config("tools") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xsltInit", {includes = {"libxslt/xslt.h"}}))
    end)
