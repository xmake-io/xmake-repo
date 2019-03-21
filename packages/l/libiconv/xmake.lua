package("libiconv")

    set_homepage("https://www.gnu.org/software/libiconv")
    set_description("Character set conversion library.")

    set_urls("https://ftp.gnu.org/gnu/libiconv/libiconv-$(version).tar.gz",
             "https://ftpmirror.gnu.org/libiconv/libiconv-$(version).tar.gz")
    add_versions("1.15", "ccf536620a45458d26ba83887a983b96827001e92a13847b45e4925cc8913178")

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--enable-static", "--disable-dependency-tracking", "--enable-extra-encodings"}
        if package:debug() then
            table.insert(configs, "--enable-debug")
        else
            table.insert(configs, "--disable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("iconv --version")
        assert(package:has_cfuncs("iconv_open", {includes = "iconv.h"}))
    end)
