package("jrl-cmakemodules")
    set_kind("binary")
    set_homepage("https://jrl-cmakemodules.readthedocs.io/en/master/")
    set_description("CMake utility toolbox")
    set_license("LGPL-3.0")

    add_urls("https://github.com/jrl-umi3218/jrl-cmakemodules/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jrl-umi3218/jrl-cmakemodules.git")

    add_versions("v1.1.2", "66cc65863d2f40fcf80881ba6053cb6d7b73f673d46e16c7d1a5eee8b158b897")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(os.isfile(path.join(package:installdir(), "share/cmake/jrl-cmakemodules/jrl-cmakemodulesConfig.cmake")))
    end)
