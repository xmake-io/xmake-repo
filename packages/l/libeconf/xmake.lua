package("libeconf")
    set_homepage("https://github.com/openSUSE/libeconf")
    set_description("A highly flexible and extensible library for parsing and managing configuration files.")
    set_license("MIT")

    add_urls("https://github.com/openSUSE/libeconf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/openSUSE/libeconf.git")

    add_versions("v0.8.0", "d50b7135483f13c1a6229a293bd5fdac77b1d827607c72cc61d13be56f58aaa2")
    add_versions("v0.7.10", "e8fee300cbbae11287d2682d185d946a1ffbd23bf02b4f97d68f2df34d8de07f")

    add_deps("cmake")

    on_install("!windows and !mingw", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("econf_readFile", {includes = "libeconf.h"}))
    end)
