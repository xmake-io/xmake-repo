package("zbar")
    set_homepage("https://github.com/mchehab/zbar")
    set_description("Library for reading bar codes from various sources")
    set_license("LGPL-2.1")

    add_urls("https://github.com/mchehab/zbar/archive/refs/tags/$(version).tar.gz")
    add_versions("0.23.93", "212dfab527894b8bcbcc7cd1d43d63f5604a07473d31a5f02889e372614ebe28")

    add_deps("autoconf", "automake", "libtool", "libiconv")

    on_install("macosx", "linux", "bsd", "mingw", "windows", "android", function (package)
        local configs = {   "--without-gtk",
                            "--without-python",
                            "--without-qt",
                            "--without-java",
	                        "--without-imagemagick",
                            "--without-dbus",
                        }
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:is_plat("linux") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        
        local cflags = {}
        local ldflags = {}
        local fetchinfo = package:dep("libiconv"):fetch()
            if fetchinfo then
                for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    table.insert(cflags, "-I" .. includedir)
                end
                for _, linkdir in ipairs(fetchinfo.linkdirs) do
                    table.insert(ldflags, "-L" .. linkdir)
                end
                for _, link in ipairs(fetchinfo.links) do
                    table.insert(ldflags, "-l" .. link)
                end
            end

        local libtool = package:dep("libtool")
        if libtool then
            os.vrun("autoreconf --force --install -I" .. libtool:installdir("share", "aclocal"))
        else
            os.vrun("autoreconf --force --install")
        end
        import("package.tools.autoconf").install(package, configs, {cflags = cflags, ldflags = ldflags})
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                zbar_image_scanner_t *scanner ;
                scanner = zbar_image_scanner_create();
                zbar_image_scanner_set_config(scanner, 0, ZBAR_CFG_ENABLE, 1);
                zbar_image_scanner_destroy(scanner);
            }
        ]]}, {includes = "zbar.h"}))
    end)
