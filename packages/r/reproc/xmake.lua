package("reproc")
    set_description("a cross-platform C/C++ library that simplifies starting, stopping and communicating with external programs.")
    set_homepage("https://github.com/DaanDeMeyer/reproc")
    set_license("MIT")

    add_urls("https://github.com/DaanDeMeyer/reproc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/DaanDeMeyer/reproc.git")

    add_versions("v14.2.5", "69467be0cfc80734b821c54ada263c8f1439f964314063f76b7cf256c3dc7ee8")
    add_versions("v14.2.4", "55c780f7faa5c8cabd83ebbb84b68e5e0e09732de70a129f6b3c801e905415dd")

    add_patches("v14.2.4", path.join(os.scriptdir(), "patches", "0001-to-head.diff"),
        "a5ed818fc36a93bf1f146e6b993e7d0e78daac9c3e5c005f7c84d3e7441f80bb")

    add_configs("c++", { description = "Build reproc C++ library.", default = true, type = "boolean" })
    add_configs("multithreaded", { description = "Enable multithreading.", default = true, type = "boolean" })

    add_deps("cmake")

    add_links("reproc++", "reproc")
    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end

    on_install(function(package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "REPROC_SHARED")
            if package:config("c++") then
                package:add("defines", "REPROCXX_SHARED")
            end
        end
        if package:config("multithreaded") and not package:is_plat("windows", "android") then
            package:add("syslinks", "pthread")
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "RelWithDebInfo"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DREPROC++=" .. (package:config("c++") and "ON" or "OFF"))
        table.insert(configs, "-DREPROC_MULTITHREADED=" .. (package:config("multithreaded") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:has_cfuncs("reproc_run", { includes = "reproc/run.h" }))
    end)
