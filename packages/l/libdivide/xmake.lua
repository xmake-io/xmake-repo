package("libdivide")
    set_kind("library", {headeronly = true})
    set_homepage("http://libdivide.com")
    set_description("Official git repository for libdivide: optimized integer division")

    add_urls("https://github.com/ridiculousfish/libdivide/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ridiculousfish/libdivide.git")
    add_versions("5.0", "01ffdf90bc475e42170741d381eb9cfb631d9d7ddac7337368bcd80df8c98356")

    on_install(function (package)
        os.cp("*.h", package:installdir("include"))
        os.cp("*.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libdivide_s16_gen(0)", {includes = "libdivide.h"}))
    end)
