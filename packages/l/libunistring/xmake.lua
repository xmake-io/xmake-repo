package("libunistring")

    set_homepage("https://www.gnu.org/software/libunistring/")
    set_description("This library provides functions for manipulating Unicode strings and for manipulating C strings according to the Unicode standard.")
    set_license("GPL-3.0")

    add_urls("https://ftpmirror.gnu.org/gnu/libunistring/libunistring-$(version).tar.gz",
             "https://ftp.gnu.org/gnu/libunistring/libunistring-$(version).tar.gz")
    add_versions("0.9.10", "a82e5b333339a88ea4608e4635479a1cfb2e01aafb925e1290b65710d43f610b")
    add_versions("1.1", "a2252beeec830ac444b9f68d6b38ad883db19919db35b52222cf827c385bdb6a")

    add_deps("libiconv")

    on_install("linux", "macosx", function (package)
        local configs = {"--disable-dependency-tracking"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs, {packagedeps = {"libiconv"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("u8_check", {includes = "unistr.h"}))
    end)
