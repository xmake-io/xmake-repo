package("speex")
    set_homepage("https://www.speex.org/")
    set_description("A free codec for free speech")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xiph/speex/archive/refs/tags/Speex-$(version).tar.gz",
             "https://github.com/xiph/speex.git")

    add_versions("1.2.1", "beaf2642e81a822eaade4d9ebf92e1678f301abfc74a29159c4e721ee70fdce0")

    add_patches("1.2.1", "patches/1.2.1/filter-subdirs.patch", "00e740f7dc7d17f1d71206b13c596d61f85e92a44cee39441c9f00f4ad93d045")
    add_patches("1.2.1", "patches/1.2.1/fix-ac-compile-ifelse.patch", "446babf535de9aa3dae30bbd3983b662a3162cf149280413eb2e483836eb2039")

    add_deps("autotools")

    on_install("linux", "macosx", "bsd", "mingw", "wasm", "cross", "iphoneos", "android@linux,macosx", function (package)
        local configs = {"--disable-binaries"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("speex_encoder_init", {includes = "speex/speex.h"}))
    end)
