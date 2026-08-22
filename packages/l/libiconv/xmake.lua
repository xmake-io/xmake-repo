package("libiconv")
    set_homepage("https://www.gnu.org/software/libiconv")
    set_description("Character set conversion library.")
    set_license("LGPL-2.0")

    set_urls("https://ftp.gnu.org/gnu/libiconv/libiconv-$(version).tar.gz",
             "https://mirrors.ustc.edu.cn/gnu/libiconv/libiconv-$(version).tar.gz",
             "https://mirror.csclub.uwaterloo.ca/gnu/libiconv/libiconv-$(version).tar.gz")

    add_versions("1.18", "3b08f5f4f9b4eb82f151a7040bfd6fe6c6fb922efe4b1659c66ea933276965e8")
    add_versions("1.17", "8f74213b56238c85a50a5329f77e06198771e70dd9a739779f4c02f65d971313")
    add_versions("1.16", "e6a1b1b589654277ee790cce3734f07876ac4ccfaecbee8afa0b649cf529cc04")
    add_versions("1.15", "ccf536620a45458d26ba83887a983b96827001e92a13847b45e4925cc8913178")

    if is_plat("macosx") then
        add_patches("1.15", path.join(os.scriptdir(), "patches", "1.15", "patch-utf8mac.diff"),
            "e8128732f22f63b5c656659786d2cf76f1450008f36bcf541285268c66cabeab")
    elseif is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_fetch("macosx", "linux", function (package, opt)
        if opt.system then
            if package:is_plat("linux") and package:has_tool("cc", "gcc", "gxx", "clang", "clangxx") then
                return {} -- libiconv is already a part of glibc (GNU iconv)
            else
                return package:find_package("system::iconv", {includes = "iconv.h"})
            end
        end
    end)

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("windows", "mingw", "android", "iphoneos", function (package)
        io.gsub("config.h.in", "%$", "")
        io.gsub("config.h.in", "# ?undef (.-)\n", "${define %1}\n")
        io.gsub("libcharset/config.h.in", "%$", "")
        io.gsub("libcharset/config.h.in", "# ?undef (.-)\n", "${define %1}\n")

        if package:is_plat("windows") then
            io.gsub("srclib/safe-read.c", "#include <unistd.h>", "#include <io.h>")
            io.gsub("srclib/progreloc.c", "#include <unistd.h>", "")
            for _, file in ipairs(os.files("**")) do
                io.gsub(file, "#include <stdbool.h>", "#include <cstdbool>")
            end
            io.gsub("config.h.in", "#  if HAVE_STDBOOL_H", "#  if 1")
            io.replace("srclib/binary-io.h", "#  define __gl_setmode _setmode", "#  include <io.h>\n#  define __gl_setmode _setmode", {plain = true})
        end
        -- Enforce #include <stdbool.h>
        if package:is_plat("android") then
            io.gsub("config.h.in", "#  if HAVE_STDBOOL_H", "#  if 1")
        end

        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), ".")
        import("package.tools.xmake").install(package, {
            relocatable = true,
            installprefix = package:installdir():gsub("\\", "\\\\"),
            vers = package:version_str()
        })
    end)

    on_install("macosx", "linux", "bsd", "cross", "wasm", function (package)
        local configs = {"--disable-dependency-tracking", "--enable-extra-encodings", "--enable-relocatable"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end

        local opt = {}
        if package:version():lt("1.18") then
            opt.cxflags = "-std=c99"
            os.vrunv("make", {"-f", "Makefile.devel", "CFLAGS=" .. (package:config("cflags") or "")})
        end
        import("package.tools.autoconf").install(package, configs, opt)
    end)

    on_test(function (package)
        if package:is_plat("linux", "bsd") or (package:is_plat("macosx") and not package:config("shared")) then
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
