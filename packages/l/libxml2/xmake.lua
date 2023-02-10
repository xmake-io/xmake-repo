package("libxml2")

    set_homepage("http://xmlsoft.org/")
    set_description("The XML C parser and toolkit of Gnome.")
    set_license("MIT")

    add_urls("https://download.gnome.org/sources/libxml2/$(version).tar.xz", {version = function (version) return format("%d.%d/libxml2-%s", version:major(), version:minor(), version) end})
    add_urls("https://gitlab.gnome.org/GNOME/libxml2.git")
    add_versions("2.10.3", "5d2cc3d78bec3dbe212a9d7fa629ada25a7da928af432c93060ff5c17ee28a9c")

    add_configs("iconv", {description = "Enable libiconv support.", default = false, type = "boolean"})
    add_configs("python", {description = "Enable the python interface.", default = false, type = "boolean"})

    add_includedirs("include/libxml2")
    if is_plat("windows") then
        add_syslinks("wsock32", "ws2_32")
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
            if package:is_cross() then
                raise("libxml2 python interface does not support cross-compilation")
            end
            if not package:config("iconv") then
                raise("libxml2 python interface requires iconv to be enabled")
            end
            package:add("deps", "python 3.x")
        end
        if package:config("iconv") then
            package:add("deps", "libiconv")
        end
    end)

    on_install("windows", function (package)
        os.cd("win32")
        local args = {"configure.js", "iso8859x=yes", "lzma=no", "zlib=no", "compiler=msvc"}
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
            io.replace("libxml_wrap.h", "XML_IGNORE_PEDANTIC_WARNINGS", "XML_IGNORE_DEPRECATION_WARNINGS")
            io.replace("setup.py", "[xml_includes]", "[xml_includes,\"" .. package:dep("libiconv"):installdir("include"):gsub("\\", "\\\\") .. "\"]", {plain = true})
            io.replace("setup.py", "WITHDLLS = 1", "WITHDLLS = 0", {plain = true})
            if not package:config("shared") then
                io.replace("setup.py", "libdirs = [", format("libdirs = [\n'%s',", package:dep("libiconv"):installdir("lib"):gsub("\\", "\\\\")), {plain = true})
                io.replace("setup.py", "platformLibs = []", "platformLibs = ['iconv','wsock32','ws2_32']", {plain = true})
                io.replace("setup.py", "\"xml2\"", "\"xml2_a\"", {plain = true})
                io.replace("setup.py", "macros  = []", "macros  = [('LIBXML_STATIC','1')]", {plain = true})
            else
                os.cp(path.join(package:installdir("bin"), "libxml2.dll"), path.join(package:installdir("lib"), "site-packages", "libxml2.dll"))
            end
            os.mkdir(path.join(package:installdir("lib"), "site-packages"))
            os.vrunv("python", {"-m", "pip", "install", "--prefix=" .. package:installdir(), "."}, {envs = {PYTHONPATH = path.join(package:installdir("lib"), "site-packages")}})
            package:addenv("PYTHONPATH", path.join(package:installdir("lib"), "site-packages"))
        end
    end)

    on_install("macosx", "linux", "iphoneos", "android", function (package)
        import("package.tools.autoconf")
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
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        local envs = autoconf.buildenvs(package)
        if package:config("python") then
            table.insert(configs, "--with-python")
            table.insert(configs, "--with-ftp")
            table.insert(configs, "--with-legacy")
            local python = package:dep("python"):fetch()
            if python then
                local cflags, ldflags
                for _, includedir in ipairs(python.sysincludedirs or python.includedirs) do
                    cflags = (cflags or "") .. " -I" .. includedir
                end
                for _, linkdir in ipairs(python.linkdirs) do
                    ldflags = (ldflags or "") .. " -L" .. linkdir
                end
                envs.PYTHON_CFLAGS  = cflags
                envs.PYTHON_LIBS = ldflags
            end
        else
            table.insert(configs, "--without-python")
        end
        autoconf.install(package, configs, {envs = envs})
        package:addenv("PATH", package:installdir("bin"))
        if package:config("python") then
            os.cd("python")
            io.replace("setup.py", "[xml_includes]", "[xml_includes,\"" .. package:dep("libiconv"):installdir("include") .. "\"]", {plain = true})
            if not package:config("shared") then
                io.replace("setup.py", "libdirs = [", format("libdirs = [\n'%s',", package:dep("libiconv"):installdir("lib")), {plain = true})
                io.replace("setup.py", "platformLibs = [\"m\",\"z\"]", "platformLibs = [\"iconv\",\"m\"]", {plain = true})
            else
                io.replace("setup.py", "platformLibs = [\"m\",\"z\"]", "platformLibs = [\"m\"]", {plain = true})
            end
            local python = package:dep("python")
            local pythonver = nil
            if python:is_system() then
                pythonver = import("core.base.semver").new(python:fetch().version)
            else
                pythonver = python:version()
            end
            os.vrunv("python3", {"-m", "pip", "install", "--prefix=" .. package:installdir(), "."}, {envs = {PYTHONPATH = path.join(package:installdir("lib"), format("python%s.%s", pythonver:major(), pythonver:minor()), "site-packages")}})
            package:addenv("PYTHONPATH", path.join(package:installdir("lib"), format("python%s.%s", pythonver:major(), pythonver:minor()), "site-packages"))
        end
    end)

    on_test(function (package)
        if package:config("python") then
            if package:is_plat("windows") then
                os.vrun("python -c \"import libxml2\"")
            else
                os.vrun("python3 -c \"import libxml2\"")
            end
        end
        assert(package:has_cfuncs("xmlNewNode", {includes = {"libxml/parser.h", "libxml/tree.h"}}))
    end)
