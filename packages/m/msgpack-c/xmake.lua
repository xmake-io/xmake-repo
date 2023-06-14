package("msgpack-c")

    set_homepage("https://msgpack.org/")
    set_description("MessagePack implementation for C")
    set_license("BSL-1.0")

    add_urls("https://github.com/msgpack/msgpack-c/releases/download/c-$(version)/msgpack-c-$(version).tar.gz")
    add_versions("4.0.0", "420fe35e7572f2a168d17e660ef981a589c9cbe77faa25eb34a520e1fcc032c8")

    add_deps("cmake")
    on_install("windows", "macosx", "linux", "mingw", function (package)
        local configs = {"-DMSGPACK_BUILD_EXAMPLES=OFF", "-DMSGPACK_BUILD_TESTS=OFF", "-DMSGPACK_GEN_COVERAGE=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("msgpack_sbuffer_init", {includes = "msgpack.h"}))
    end)
