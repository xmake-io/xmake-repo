package("libisl")

    set_homepage("http://isl.gforge.inria.fr/")
    set_description("Integer Set Library")

    set_urls("https://github.com/xmake-mirror/isl/archive/refs/tags/isl-$(version).tar.gz",
             "git@github.com:xmake-mirror/isl.git")
    add_versions("0.24", "63eda93f0a79d812a5f051fa57279b8216f32a68204a1a81caa212a392887b7f")
    add_versions("0.23", "d9fc290a330227c77fc7f58e4532064b946b55027cd1513b48be62f402361d79")
    add_versions("0.22", "f9785afcd207683ff1822d79f04cf879e350d55dc75658513642e23bcf42886d")

    add_deps("autoconf", "automake", "libtool", "gmp")

    on_install("linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        table.insert(configs, "--with-gmp-prefix=" .. package:dep("gmp"):installdir())
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("isl_version", {includes = "isl/version.h"}))
    end)
