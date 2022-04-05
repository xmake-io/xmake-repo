package("libxml2")

    set_homepage("http://xmlsoft.org/")
    set_description("The XML C parser and toolkit of Gnome.")
    set_license("MIT")

    set_urls("http://xmlsoft.org/sources/libxml2-$(version).tar.gz",
             "https://ftp.osuosl.org/pub/blfs/conglomeration/libxml2/libxml2-$(version).tar.gz")
    add_urls("https://gitlab.gnome.org/GNOME/libxml2.git")
    add_versions("2.9.9", "94fb70890143e3c6549f265cee93ec064c80a84c42ad0f23e85ee1fd6540a871")
    add_versions("2.9.10", "aafee193ffb8fe0c82d4afef6ef91972cbaf5feea100edc2f262750611b4be1f")
    add_versions("2.9.12", "c8d6681e38c56f172892c85ddc0852e1fd4b53b4209e7f4ebf17f7e2eae71d92")

    add_patches("2.9.12", path.join(os.scriptdir(), "patches", "2.9.12", "msvc.patch"), "b978048ad1caf9c63e3b2eee685ea2e586812d80deb1e47b18ad2cae36edd201")

    add_configs("iconv", {description = "Enable libiconv support.", default = false, type = "boolean"})
    add_configs("python", {description = "Enable the python interface.", default = false, type = "boolean"})

    add_includedirs("include/libxml2")
    if is_plat("windows") then
        add_syslinks("ws2_32")
    else
        add_links("xml2")
    end
    if is_plat("linux") then
        add_extsources("pkgconfig::libxml-2.0", "apt::libxml2-dev", "pacman::libxml2")
        add_syslinks("m")
    end

    on_load("windows", "macosx", "linux", "iphoneos", "android", function (package)
        if package:is_plat("windows") then
            if not package:config("shared") then
                package:add("defines", "LIBXML_STATIC")
            end
        else
            if package:gitref() then
                package:add("deps", "autoconf", "automake", "libtool", "pkg-config")
            end
        end
        if package:config("python") then
            if not package:is_plat(os.host()) then
                raise("libxml2 python interface does not support cross-compilation")
            end
            if not package:config("iconv") then
                raise("libxml2 python interface requires iconv to be enabled")
            end
            package:add("deps", "python 3.x", {private = true})
        end
        if package:config("iconv") then
            package:add("deps", "libiconv")
        end
    end)

    on_install("windows", function (package)
        os.cd("win32")
        local args = {"configure.js", "iso8859x=yes", "zlib=no", "compiler=msvc"}
        table.insert(args, "cruntime=/" .. package:config("vs_runtime"))
        table.insert(args, "debug=" .. (package:debug() and "yes" or "no"))
        table.insert(args, "iconv=" .. (package:config("iconv") and "yes" or "no"))
        table.insert(args, "python=" .. (package:config("python") and "yes" or "no"))
        table.insert(args, "prefix=" .. package:installdir())
        if package:config("iconv") then
            table.insert(args, "include=" .. package:dep("libiconv"):installdir("include"))
            table.insert(args, "lib=" .. package:dep("libiconv"):installdir("lib"))
        end
        os.vrunv("cscript", args)
        import("package.tools.nmake").install(package, {"/f", "Makefile.msvc"})
        os.tryrm(path.join(package:installdir("bin"), "run*.exe"))
        os.tryrm(path.join(package:installdir("bin"), "test*.exe"))
        os.tryrm(path.join(package:installdir("lib"), "libxml2_a_dll.lib"))
        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"), "libxml2_a.lib"))
        else
            os.tryrm(path.join(package:installdir("lib"), "libxml2.lib"))
            os.tryrm(path.join(package:installdir("bin"), "libxml2.dll"))
        end
        package:addenv("PATH", package:installdir("bin"))
        if package:config("python") then
            os.cd("../python")
            io.replace("setup.py", "/opt/include", package:dep("libiconv"):installdir("include"):gsub("\\", "\\\\"), {plain = true})
            io.replace("setup.py", "WITHDLLS = 1", "WITHDLLS = 0", {plain = true})
            if not package:config("shared") then
                io.replace("setup.py", "libdirs = [", format("libdirs = [\n'%s',", package:dep("libiconv"):installdir("lib"):gsub("\\", "\\\\")), {plain = true})
                io.replace("setup.py", "platformLibs = []", "platformLibs = ['iconv','wsock32','ws2_32']", {plain = true})
                io.replace("setup.py", "\"xml2\"", "\"xml2_a\"", {plain = true})
                io.replace("setup.py", "macros  = []", "macros  = [('LIBXML_STATIC','1')]", {plain = true})
            else
                os.cp(path.join(package:installdir("bin"), "libxml2.dll"), path.join(package:installdir("lib"), "site-packages", "libxml2.dll"))
            end
            os.vrun("python setup.py install --prefix=\"" .. package:installdir() .. "\"")
            package:addenv("PYTHONPATH", path.join(package:installdir("lib"), "site-packages"))
        end
    end)

    on_install("macosx", "linux", "iphoneos", "android", function (package)
        local configs = {"--disable-dependency-tracking",
                         "--without-lzma",
                         "--without-zlib"}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
            table.insert(configs, "--enable-static=no")
        else
            table.insert(configs, "--enable-shared=no")
            table.insert(configs, "--enable-static=yes")
        end
        if package:config("iconv") then
            local iconvdir
            local iconv = package:dep("libiconv"):fetch()
            if iconv then
                iconvdir = table.wrap(iconv.sysincludedirs or iconv.includedirs)[1]
            end
            if iconvdir then
                table.insert(configs, "--with-iconv=" .. path.directory(iconvdir))
            else
                table.insert(configs, "--with-iconv")
            end
        else
            table.insert(configs, "--without-iconv")
        end
        if package:config("python") then
            table.insert(configs, "--with-python")
        else
            table.insert(configs, "--without-python")
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
        package:addenv("PATH", package:installdir("bin"))
        if package:config("python") then
            os.cd("python")
            io.replace("setup.py", "\"/usr/include\",\n\"/usr/local/include\",\n\"/opt/include\",", "\"" .. package:dep("libiconv"):installdir("include") .. "\",", {plain = true})
            if not package:config("shared") then
                io.replace("setup.py", "libdirs = [", format("libdirs = [\n'%s',", package:dep("libiconv"):installdir("lib")), {plain = true})
                io.replace("setup.py", "platformLibs = [\"m\",\"z\"]", "platformLibs = [\"iconv\",\"m\"]", {plain = true})
            else
                io.replace("setup.py", "platformLibs = [\"m\",\"z\"]", "platformLibs = [\"m\"]", {plain = true})
            end
            os.vrun("python setup.py install --prefix=\"" .. package:installdir() .. "\"")
            local pythonver = package:dep("python"):version()
            package:addenv("PYTHONPATH", path.join(package:installdir("lib"), format("python%s.%s", pythonver:major(), pythonver:minor()), "site-packages"))
        end
    end)

    on_test(function (package)
        if package:config("python") then
            os.vrun("python3 -c \"import libxml2\"")
        end
        assert(package:has_cfuncs("xmlNewNode", {includes = {"libxml/parser.h", "libxml/tree.h"}}))
    end)
