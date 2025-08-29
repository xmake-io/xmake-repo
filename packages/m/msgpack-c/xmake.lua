package("msgpack-c")
    set_homepage("https://msgpack.org/")
    set_description("MessagePack implementation for C")
    set_license("BSL-1.0")

    add_urls("https://github.com/msgpack/msgpack-c/releases/download/c-$(version)/msgpack-c-$(version).tar.gz")
    add_versions("6.1.0", "674119f1a85b5f2ecc4c7d5c2859edf50c0b05e0c10aa0df85eefa2c8c14b796")
    add_versions("6.0.2", "5e90943f6f5b6ff6f4bda9146ada46e7e455af3a77568f6d503f35618c1b2a12")
    add_versions("6.0.1", "a349cd9af28add2334c7009e331335af4a5b97d8558b2e9804d05f3b33d97925")
    add_versions("4.0.0", "420fe35e7572f2a168d17e660ef981a589c9cbe77faa25eb34a520e1fcc032c8")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DMSGPACK_BUILD_EXAMPLES=OFF", "-DMSGPACK_BUILD_TESTS=OFF", "-DMSGPACK_GEN_COVERAGE=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("msgpack_sbuffer_init", {includes = "msgpack.h"}))
    end)
