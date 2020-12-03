package("libiconv")

    set_homepage("https://www.gnu.org/software/libiconv")
    set_description("Character set conversion library.")

    set_urls("https://ftp.gnu.org/gnu/libiconv/libiconv-$(version).tar.gz",
             "https://ftpmirror.gnu.org/libiconv/libiconv-$(version).tar.gz")
    add_versions("1.16", "e6a1b1b589654277ee790cce3734f07876ac4ccfaecbee8afa0b649cf529cc04")
    add_versions("1.15", "ccf536620a45458d26ba83887a983b96827001e92a13847b45e4925cc8913178")

    if is_plat("macosx") then
        add_patches("1.15", "https://raw.githubusercontent.com/Homebrew/patches/9be2793af/libiconv/patch-utf8mac.diff",
                            "e8128732f22f63b5c656659786d2cf76f1450008f36bcf541285268c66cabeab")
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-dependency-tracking", "--enable-extra-encodings"}
        if package:debug() then
            table.insert(configs, "--enable-debug")
        else
            table.insert(configs, "--disable-debug")
        end
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
            table.insert(configs, "--enable-static=no")
        else
            table.insert(configs, "--enable-static=yes")
            table.insert(configs, "--enable-shared=no")
        end
        os.vrunv("make", {"-f", "Makefile.devel", "CFLAGS=" .. (package:config("cflags") or "")})
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("iconv --version")
        assert(package:has_cfuncs("iconv_open(0, 0);", {includes = "iconv.h"}))
    end)

