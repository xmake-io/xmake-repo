package("dlfcn-win32")
    set_homepage("https://github.com/dlfcn-win32/dlfcn-win32")
    set_description("Official dlfcn-win32 repo")
    set_license("MIT")

    add_urls("https://github.com/dlfcn-win32/dlfcn-win32/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dlfcn-win32/dlfcn-win32.git")

    add_versions("v1.4.1", "30a9f72bdf674857899eb7e553df1f0d362c5da2a576ae51f886e1171fbdb399")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        if package:config("shared") then
            package:add("defines", "DLFCN_WIN32_SHARED")
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dlopen", {includes = "dlfcn.h"}))
    end)
