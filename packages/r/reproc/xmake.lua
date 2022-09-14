package("reproc")

    set_description("a cross-platform C/C++ library that simplifies starting, stopping and communicating with external programs.")
    set_homepage("https://github.com/DaanDeMeyer/reproc")
    set_license("MIT")

    add_urls("https://github.com/DaanDeMeyer/reproc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/DaanDeMeyer/reproc.git")
    add_versions("v14.2.4", "55c780f7faa5c8cabd83ebbb84b68e5e0e09732de70a129f6b3c801e905415dd")

    add_deps("cmake")

    if is_plat("linux") or is_plat("mingw") then
        add_syslinks("pthread")
    end
    if is_plat("windows") or is_plat("mingw") then
        add_syslinks("ws2_32")
    end

    add_configs("c++", { description = "Build reproc C++ library.", default = true, type = "boolean" })

    on_install(function(package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "RelWithDebInfo"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DREPROC++=" .. (package:config("c++") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, { buildir = "build" })
    end)

    on_test(function(package)
        assert(package:has_cfuncs("reproc_run", { includes = "reproc/run.h" }))
    end)
