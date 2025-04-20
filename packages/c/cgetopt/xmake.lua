package("cgetopt")

    set_homepage("https://github.com/xq114/cgetopt/")
    set_description("A GNU getopt() implementation written in pure C.")
    set_license("zlib")

    add_urls("https://github.com/xq114/cgetopt/archive/v$(version).tar.gz")
    add_versions("1.0", "c93fe91041752f4231e07894d24354ee079317e40c30897bd664766ef4872279")

    on_install(function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("getopt", {includes = "getopt.h"}))
    end)
