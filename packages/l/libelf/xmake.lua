package("libelf")

    set_homepage("https://web.archive.org/web/20181111033959/www.mr511.de/software/english.html")
    set_description("ELF object file access library")

    set_urls("https://github.com/xmake-mirror/libelf/releases/download/$(version)/libelf-$(version).tar.gz",
             "https://github.com/xmake-mirror/libelf.git")
    add_versions("0.8.13", "591a9b4ec81c1f2042a97aa60564e0cb79d041c52faa7416acb38bc95bd2c76d")

    add_includedirs("include", "include/libelf")

    add_deps("autotools")

    on_install("cross", "linux", "android@linux,macosx", function (package)
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
        os.rm("configure", "config.guess", "config.sub")
        local automake = package:dep("automake")
        if automake and not automake:is_system() then
            local automake_dir = path.join(automake:installdir(), "share", "automake-*")
            os.cp(path.join(automake_dir, "config.guess"), ".")
            os.cp(path.join(automake_dir, "config.sub"), ".")
        else
            import("net.http")
            import("core.base.global")
            http.download("http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD", path.join(package:buildir(), "config.guess"), {insecure = global.get("insecure-ssl")})
            http.download("http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD", path.join(package:buildir(), "config.sub"), {insecure = global.get("insecure-ssl")})
        end
        import("package.tools.autoconf").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gelf_getsym", {includes = "libelf/gelf.h"}))
        assert(package:has_cfuncs("elf_begin", {includes = "libelf/libelf.h"}))
    end)
