package("mxml")

    set_homepage("https://www.msweet.org/mxml/")
    set_description("Mini-XML is a tiny XML library that you can use to read and write XML and XML-like data files in your application without requiring large non-standard libraries.")
    set_license("Apache-2.0")

    add_urls("https://github.com/michaelrsweet/mxml/releases/download/v3.3/mxml-3.3.zip")
    add_versions("3.3.1", "fca59b0d7fae2b9165c223cdce68e45dbf41e21e5e53190d8b214218b8353380")
    add_versions("3.3", "fca59b0d7fae2b9165c223cdce68e45dbf41e21e5e53190d8b214218b8353380")

    if is_plat("macosx", "linux") then
        add_syslinks("pthread")
    end
    on_install("windows", "macosx", "linux", function (package)
        io.gsub("config.h.in", "#undef (.-)\n", "${define %1}\n")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            includes("check_cfuncs.lua")
            includes("check_ctypes.lua")
            if is_plat("macosx", "linux") then
                set_configvar("HAVE_PTHREAD_H", 1)
            end
            configvar_check_ctypes("HAVE_LONG_LONG_INT", "long long int")
            configvar_check_cfuncs("HAVE_SNPRINTF", "snprintf", {includes = "stdio.h"})
            configvar_check_cfuncs("HAVE_VASPRINTF", "vasprintf", {includes = "stdio.h", defines = "_GNU_SOURCE"})
            configvar_check_cfuncs("HAVE_VSNPRINTF", "vsnprintf", {includes = "stdio.h"})
            configvar_check_cfuncs("HAVE_STRDUP", "strdup", {includes = "string.h"})
            configvar_check_cfuncs("HAVE_STRLCAT", "strlcat", {includes = "string.h"})
            configvar_check_cfuncs("HAVE_STRLCPY", "strlcpy", {includes = "string.h"})
            target("mxml")
                set_kind("$(kind)")
                add_files("mxml-*.c")
                add_configfiles("config.h.in")
                add_includedirs("$(buildir)")
                add_headerfiles("mxml.h")
                if is_plat("macosx", "linux") then
                    add_syslinks("pthread")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mxmlLoadFile", {includes = "mxml.h"}))
    end)
