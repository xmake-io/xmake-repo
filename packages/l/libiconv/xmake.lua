package("libiconv")

    set_homepage("https://www.gnu.org/software/libiconv")
    set_description("Character set conversion library.")

    set_urls("https://ftp.gnu.org/gnu/libiconv/libiconv-$(version).tar.gz",
             "https://ftpmirror.gnu.org/libiconv/libiconv-$(version).tar.gz")
    add_versions("1.17", "8f74213b56238c85a50a5329f77e06198771e70dd9a739779f4c02f65d971313")
    add_versions("1.16", "e6a1b1b589654277ee790cce3734f07876ac4ccfaecbee8afa0b649cf529cc04")
    add_versions("1.15", "ccf536620a45458d26ba83887a983b96827001e92a13847b45e4925cc8913178")

    if is_plat("macosx") then
        add_patches("1.15", path.join(os.scriptdir(), "patches", "1.15", "patch-utf8mac.diff"),
            "e8128732f22f63b5c656659786d2cf76f1450008f36bcf541285268c66cabeab")
    elseif is_plat("android") then
        add_patches("1.x", path.join(os.scriptdir(), "patches", "1.16", "makefile.in.patch"),
            "d09e4212040f5adf1faa5cf5a9a18f6f79d4cdce9affb05f2e75df2ea3b3d686")
    end

    on_fetch("macosx", "linux", function (package, opt)
        if opt.system then
            if package:is_plat("linux") then
                return {} -- on linux libiconv is already a part of glibc
            else
                return package:find_package("system::iconv", {includes = "iconv.h"}) or package:find_package("system::intl", {includes = "iconv.h"})
            end
        end
    end)

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("windows", "mingw", function (package)
        io.gsub("config.h.in", "%$", "")
        io.gsub("config.h.in", "# ?undef (.-)\n", "${define %1}\n")
        io.gsub("libcharset/config.h.in", "%$", "")
        io.gsub("libcharset/config.h.in", "# ?undef (.-)\n", "${define %1}\n")
        io.gsub("srclib/safe-read.c", "#include <unistd.h>", "")
        io.gsub("srclib/progreloc.c", "#include <unistd.h>", "")
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), ".")
        import("package.tools.xmake").install(package, {
            relocatable = true,
            installprefix = package:installdir():gsub("\\", "\\\\"),
            vers = package:version_str()
        })
    end)

    on_install("macosx", "linux", "cross", "android", function (package)
        local configs = {"--disable-dependency-tracking", "--enable-extra-encodings"}
        if not package:is_plat("macosx") then
            table.insert(configs, "--enable-relocatable")
        end
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:is_plat("android") then
            io.replace("./configure", "#define gid_t int", "")
            io.replace("./configure", "#define uid_t int", "")
        end
        os.vrunv("make", {"-f", "Makefile.devel", "CFLAGS=" .. (package:config("cflags") or "")})
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        if package:is_plat("macosx", "linux") then
            os.vrun("iconv --version")
        end
        assert(package:check_csnippets({test = [[
            #include "iconv.h"
            void test() {
                char charset[5] = "12345";
                iconv_t cd = iconv_open("WCHAR_T", charset);
            }
        ]]}))
    end)

