package("g2o")
    set_homepage("http://openslam.org/g2o.html")
    set_description("g2o: A General Framework for Graph Optimization")

    add_urls("https://github.com/RainerKuemmerle/g2o/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return version:gsub("%.", "") .. "_git"
    end})
    add_urls("https://github.com/RainerKuemmerle/g2o.git")
    add_versions("2020.12.23", "20af80edf8fd237e29bd21859b8fc734e615680e8838824e8b3f120c5f4c1672")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DG2O_BUILD_APPS=OFF", "-DG2O_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("foo", {includes = "foo.h"}))
    end)
