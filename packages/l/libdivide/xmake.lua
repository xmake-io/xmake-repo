package("libdivide")
    set_kind("library", {headeronly = true})
    set_homepage("http://libdivide.com")
    set_description("Official git repository for libdivide: optimized integer division")

    add_urls("https://github.com/ridiculousfish/libdivide/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ridiculousfish/libdivide.git")
    add_versions("5.0", "01ffdf90bc475e42170741d381eb9cfb631d9d7ddac7337368bcd80df8c98356")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DBUILD_TESTS=OFF"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libdivide_s16_gen(0)", {includes = "libdivide.h"}))
    end)
