package("notcurses")
    set_homepage("https://nick-black.com/dankwiki/index.php/Notcurses")
    set_description("blingful character graphics/TUI library. definitely not curses.")

    add_urls("https://github.com/dankamongmen/notcurses/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dankamongmen/notcurses.git")

    add_versions("v3.0.9", "e5cc02aea82814b843cdf34dedd716e6e1e9ca440cf0f899853ca95e241bd734")

    add_deps("cmake", "doctest")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("notcurses_version", {includes = "notcurses.h"}))
    end)
