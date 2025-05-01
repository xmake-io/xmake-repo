package("libelf")
    set_homepage("https://web.archive.org/web/20181111033959/www.mr511.de/software/english.html")
    set_description("ELF object file access library")

    set_urls("https://github.com/xmake-mirror/libelf/releases/download/$(version)/libelf-$(version).tar.gz",
             "https://github.com/xmake-mirror/libelf.git")

    add_versions("0.8.13", "591a9b4ec81c1f2042a97aa60564e0cb79d041c52faa7416acb38bc95bd2c76d")

    add_resources("0.8.13", "guess", "https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=00b15927496058d23e6258a28d8996f87cf1f191", "e3d148130e9151735f8b9a8e69a70d06890ece51468a9762eb7ac0feddddcc2f")
    add_resources("0.8.13", "sub", "https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=00b15927496058d23e6258a28d8996f87cf1f191", "11c54f55c3ac99e5d2c3dc2bb0bcccbf69f8223cc68f6b2438daa806cf0d16d8")

    add_includedirs("include", "include/libelf")

    on_install("cross", "linux", "android", function (package)
        local configs = {"--disable-dependency-tracking",
                         "--disable-compat"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        local cxflags = {}
        if package:is_plat("android") then
            io.replace("lib/private.h", "HAVE_MEMMOVE", "1")
            io.replace("lib/private.h", "HAVE_MEMCPY", "1")
            io.replace("lib/private.h", "STDC_HEADERS", "1")
            table.insert(cxflags, "-D__LIBELF64=1")
            table.insert(cxflags, "-D__libelf_u64_t=uint64_t")
            table.insert(cxflags, "-D__libelf_i64_t=int64_t")
            package:add("defines", "__LIBELF64=1")
            package:add("defines", "__libelf_u64_t=uint64_t")
            package:add("defines", "__libelf_i64_t=int64_t")
        end
        os.cp(path.join(package:resourcedir("guess"), "../config.sub"), "config.guess")
        os.cp(path.join(package:resourcedir("sub"), "../config.sub"), "config.sub")
        import("package.tools.autoconf").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gelf_getsym", {includes = "libelf/gelf.h"}))
        assert(package:has_cfuncs("elf_begin", {includes = "libelf/libelf.h"}))
    end)
