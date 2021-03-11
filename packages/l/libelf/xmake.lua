package("libelf")

    set_homepage("https://web.archive.org/web/20181111033959/www.mr511.de/software/english.html")
    set_description("ELF object file access library")

    set_urls("https://dl.bintray.com/homebrew/mirror/libelf-$(version).tar.gz")
    add_versions("0.8.13", "591a9b4ec81c1f2042a97aa60564e0cb79d041c52faa7416acb38bc95bd2c76d")

    add_includedirs("include", "include/libelf")

    on_install("linux", function (package)
        local configs = {"--disable-dependency-tracking",
                         "--disable-compat"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        local cxflags
        if package:config("pic") ~= false then
            cxflags = "-fPIC"
        end
        import("package.tools.autoconf").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("elf_begin", {includes = "libelf/gelf.h"}))
    end)
