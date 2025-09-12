package("libxls")
    set_description("Read binary Excel files from C/C++.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/libxls/libxls/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libxls/libxls.git")
    add_versions("v1.6.3", "587c9f0ebb5647eb68ec1e0ed8c3f7f6102622d6dd83473a21d3a36dee04eed7")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("libiconv")
    on_install("!windows", function (package)
        io.writefile("xmake.lua", ([[
            add_rules("mode.debug", "mode.release")
            add_requires("libiconv")
            target("xlsreader")
                set_kind("$(kind)")
                set_languages("gnu99")

                add_files("src/**.c")
                remove_files("src/xls2csv.c")
                add_includedirs("include")
                add_headerfiles("include/(**.h)")

                add_packages("libiconv")
                add_defines("HAVE_ICONV")

                on_config(function(target)
                    if target:has_cincludes("xlocale.h") then
                        target:add("defines", "HAVE_XLOCALE_H", {public = true})
                    end
                    if target:has_cfuncs("wcstombs_l") then
                        target:add("defines", "HAVE_WCSTOMBS_L", {public = true})
                    end
                end)

                add_cflags("-pedantic-errors")
                if is_plat("mingw", "cygwin") then
                    add_ldflags("-no-undefined")
                end
                if is_plat("mingw") then
                    add_cflags("-D_spawnv=spawnv")
                end

                add_defines("ICONV_CONST=")
                add_defines("PACKAGE_VERSION=\"%s\"")
        ]]):format(package:version_str():sub(2)))

        for _, path in ipairs(os.files("src/**.c")) do
            io.replace(path, [[#include "config.h"]], "", {plain = true})
        end

        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xls_open_file", {includes = "xls.h"}))
    end)
