package("libelf")

    set_homepage("https://web.archive.org/web/20181111033959/www.mr511.de/software/english.html")
    set_description("ELF object file access library")

    set_urls("https://github.com/xmake-mirror/libelf/releases/download/$(version)/libelf-$(version).tar.gz",
             "https://github.com/xmake-mirror/libelf.git")
    add_versions("0.8.13", "591a9b4ec81c1f2042a97aa60564e0cb79d041c52faa7416acb38bc95bd2c76d")

    add_includedirs("include", "include/libelf")

    on_install("linux", "android", function (package)
        local configs = {"--disable-dependency-tracking",
                         "--disable-compat"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        local cxflags = {}
        if package:config("pic") ~= false then
            table.insert(cxflags, "-fPIC")
        end
        if package:is_plat("android") then
            io.replace("./configure", "#define off_t long", "")
            io.replace("lib/private.h", "HAVE_MEMMOVE", "1")
            io.replace("lib/private.h", "HAVE_MEMCPY", "1")
            table.insert(cxflags, "-D__LIBELF64=1")
            table.insert(cxflags, "-D__LIBELF64_LINUX=1")
            table.insert(cxflags, "-D__libelf_u64_t=uint64_t")
            table.insert(cxflags, "-D__libelf_i64_t=int64_t")
            package:add("defines", "__LIBELF64=1")
            package:add("defines", "__LIBELF64_LINUX=1")
            package:add("defines", "__libelf_u64_t=uint64_t")
            package:add("defines", "__libelf_i64_t=int64_t")
        end
        io.replace("./configure", "main(){return(0);}", "int main(){return(0);}", {plain = true})
        io.replace("lib/version.c", "#include <private.h>", "#include <private.h>\n#include <stdlib.h>", {plain = true})
        import("package.tools.autoconf").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gelf_getsym", {includes = "libelf/gelf.h"}))
        assert(package:has_cfuncs("elf_begin", {includes = "libelf/libelf.h"}))
    end)
