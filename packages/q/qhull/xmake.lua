package("qhull")
    set_homepage("http://www.qhull.org/")
    set_description("Qhull computes the convex hull, Delaunay triangulation, Voronoi diagram, halfspace intersection about a point, furthest-site Delaunay triangulation, and furthest-site Voronoi diagram.")

    add_urls("https://github.com/qhull/qhull/archive/refs/tags/$(version).tar.gz",
             "https://github.com/qhull/qhull.git")

    add_versions("2020.2", "59356b229b768e6e2b09a701448bfa222c37b797a84f87f864f97462d8dbc7c5")

    add_deps("cmake")

    on_install(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "qh_dllimport")
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("qh_addpoint", {includes = "libqhull/libqhull.h"}))
    end)
