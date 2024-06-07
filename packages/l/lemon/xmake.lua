package("lemon")

    set_homepage("https://lemon.cs.elte.hu/trac/lemon")
    set_description("Library for Efficient Modeling and Optimization in Networks.")
    set_license("BSL-1.0")

    add_urls("http://lemon.cs.elte.hu/pub/sources/lemon-$(version).tar.gz")
    add_versions("1.3.1", "71b7c725f4c0b4a8ccb92eb87b208701586cf7a96156ebd821ca3ed855bad3c8")

    if is_plat("windows", "mingw") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    on_install("windows", "macosx", "linux", "mingw", "cross", function (package)
        local configs = {"-DLEMON_ENABLE_GLPK=OFF", "-DLEMON_ENABLE_ILOG=OFF", "-DLEMON_ENABLE_COIN=OFF", "-DLEMON_ENABLE_SOPLEX=OFF", "-DCMAKE_CXX_STANDARD=14"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("lemon::SmartDigraph", {configs = {languages = "c++11"}, includes = "lemon/smart_graph.h"}))
    end)
