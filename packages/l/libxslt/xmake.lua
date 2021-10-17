package("libxslt")

    set_homepage("http://xmlsoft.org/XSLT/")
    set_description("Libxslt is the XSLT C library developed for the GNOME project.")
    set_license("MIT")

    add_urls("http://xmlsoft.org/sources/libxslt-$(version).tar.gz")
    add_versions("1.1.34", "98b1bd46d6792925ad2dfe9a87452ea2adebf69dcb9919ffd55bf926a7f93f7f")

    add_configs("iconv", {description = "Enable libiconv support.", default = false, type = "boolean"})

    on_load("windows", "macosx", "linux", function (package)
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "LIBXSLT_STATIC")
        end
        package:add("deps", "libxml2", {configs = {iconv = package:config("iconv")}})
    end)

    on_install("windows", function (package)
        io.replace("libxslt/xsltconfig.h.in", "@WITH_PROFILER@", "0", {plain = true})
        os.cd("win32")
        local args = {"configure.js", "compiler=msvc", "iconv=no"}
        table.insert(args, "cruntime=/" .. package:config("vs_runtime"))
        table.insert(args, "debug=" .. (package:debug() and "yes" or "no"))
        local cflags = "/DLIBXML_STATIC \"/I$(INCPREFIX)\" \"/I" .. package:dep("libxml2"):installdir("include", "libxml2") .. "\""
        local ldflags = "ws2_32.lib \"/LIBPATH:$(LIBPREFIX)\" \"/LIBPATH:" .. package:dep("libxml2"):installdir("lib") .. "\""
        io.replace("Makefile.msvc", "libxml2.lib", "libxml2_a.lib", {plain = true})
        io.replace("Makefile.msvc", "/I$(INCPREFIX)", cflags, {plain = true})
        io.replace("Makefile.msvc", "/LIBPATH:$(LIBPREFIX)", ldflags, {plain = true})
        table.insert(args, "prefix=" .. package:installdir())
        os.vrunv("cscript", args)
        import("package.tools.nmake").install(package, {"/f", "Makefile.msvc"})
        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"), "libxslt_a.lib"))
            os.tryrm(path.join(package:installdir("lib"), "libexslt_a.lib"))
        else
            os.tryrm(path.join(package:installdir("lib"), "libxslt.lib"))
            os.tryrm(path.join(package:installdir("lib"), "libexslt.lib"))
            os.tryrm(path.join(package:installdir("bin"), "libxslt.dll"))
            os.tryrm(path.join(package:installdir("bin"), "libexslt.dll"))
        end
        package:addenv("PATH", "bin")
    end)

    on_install("macosx", "linux", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
            table.insert(configs, "--enable-static=no")
        else
            table.insert(configs, "--enable-shared=no")
            table.insert(configs, "--enable-static=yes")
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xsltInit", {includes = {"libxslt/xslt.h"}}))
    end)
