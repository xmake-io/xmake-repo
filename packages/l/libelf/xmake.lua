package("libelf")
    set_homepage("https://web.archive.org/web/20181111033959/www.mr511.de/software/english.html")
    set_description("ELF object file access library")

    set_urls("https://github.com/xmake-mirror/libelf/releases/download/$(version)/libelf-$(version).tar.gz",
             "https://github.com/xmake-mirror/libelf.git")

    add_versions("0.8.13", "591a9b4ec81c1f2042a97aa60564e0cb79d041c52faa7416acb38bc95bd2c76d")
    add_resources("0.8.13", "config", "https://dev.gentoo.org/~sam/distfiles/sys-devel/gnuconfig/gnuconfig-20240728.tar.xz", "6e3a7389d780cb0cf81bec0bba96ca278d5b76afd548352f70b4a444344430b7")

    add_includedirs("include", "include/libelf")
    
    if not is_subhost("windows") then
        add_deps("autotools")
    end

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
        if not is_subhost("windows") then
            os.rm("configure")
        else
            io.replace("lib/Makefile.in", [[$(SHELL) $(top_srcdir)/mkinstalldirs $(instroot)$$dir;]], [["$(SHELL)" "$(top_srcdir)/mkinstalldirs" "$(instroot)$$dir";]], {plain = true})
            io.replace("po/Makefile.in", [[$(SHELL) $(top_srcdir)/mkinstalldirs $(instroot)$$dir;]], [["$(SHELL)" "$(top_srcdir)/mkinstalldirs" "$(instroot)$$dir";]], {plain = true})
        end
        os.cp(path.join(package:resourcedir("config"), "config.guess"), "config.guess")
        os.cp(path.join(package:resourcedir("config"), "config.sub"), "config.sub")
        import("package.tools.autoconf").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gelf_getsym", {includes = "libelf/gelf.h"}))
        assert(package:has_cfuncs("elf_begin", {includes = "libelf/libelf.h"}))
    end)
