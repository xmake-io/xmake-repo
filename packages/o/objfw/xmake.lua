package("objfw")
    set_homepage("https://objfw.nil.im")
    set_description("Portable framework for the Objective-C language.")

    add_urls("https://github.com/ObjFW/ObjFW.git")
    add_versions("2023.03.18", "86cec7d17dd323407f30fc5947e0e92cc307e869")

    if is_host("linux", "macosx") then
        add_deps("autoconf", "automake", "libtool")
    end

    if is_plat("macosx") then
        add_syslinks("objc")
        add_frameworks("CoreFoundation")
    end

    add_configs("tls", { description = "Enable TLS support.", default = false, values = { true, false, "openssl", "gnutls", "securetransport" } })
    add_configs("rpath", { description = "Enable rpath.", default = true, type = "boolean" })
    add_configs("runtime", { description = "Use the included runtime, not recommended for macOS!", default = not is_plat("macosx"), type = "boolean" })
    add_configs("seluid24", { description = "Use 24 bit instead of 16 bit for selector UIDs.", default = false, type = "boolean" })
    add_configs("unicode_tables", { description = "Enable Unicode tables.", default = true, type = "boolean" })

    add_configs("codepage_437", { description = "Enable codepage 437 support.", default = true, type = "boolean" })
    add_configs("codepage_850", { description = "Enable codepage 850 support.", default = true, type = "boolean" })
    add_configs("codepage-858", { description = "Enable codepage 858 support.", default = true, type = "boolean" })
    add_configs("iso_8859_2", { description = "Enable ISO-8859-2 support.", default = true, type = "boolean" })
    add_configs("iso_8859_3", { description = "Enable ISO-8859-3 support.", default = true, type = "boolean" })
    add_configs("iso_8859_15", { description = "Enable ISO-8859-15 support.", default = true, type = "boolean" })
    add_configs("koi8_r", { description = "Enable KOI8-R support.", default = true, type = "boolean" })
    add_configs("koi8_u", { description = "Enable KOI8-U support.", default = true, type = "boolean" })
    add_configs("mac_roman", { description = "Enable Mac Roman encoding support.", default = true, type = "boolean" })
    add_configs("windows_1251", { description = "Enable windows 1251 support.", default = true, type = "boolean" })
    add_configs("windows_1252", { description = "Enable windows 1252 support.", default = true, type = "boolean" })

    add_configs("threads", { description = "Enable threads.", default = true, type = "boolean" })
    add_configs("compiler_tls", { description = "Enable compiler thread local storage (TLS).", default = true, type = "boolean" })
    add_configs("files", { description = "Enable files.", default = true, type = "boolean" })
    add_configs("sockets", { description = "Enable sockets.", default = true, type = "boolean" })

    add_configs("arc", { description = "Enable Automatic Reference Counting (ARC) support.", default = true, type = "boolean" })

    on_load(function (package)
        local tls = package:config("tls")
        if type(tls) == "boolean" then
            if tls then
                package:add("deps", "openssl")
            end
        elseif tls then
            if tls == "openssl" then
                package:add("deps", "openssl")
            else
                raise("no package %s for objfw!", tls)
            end
        end
    end)

    on_install("linux", "macosx", function (package)
        local configs = {}
        local tls = package:config("tls")
        if type(tls) == "boolean" then
            tls = tls and "yes" or "no"
        end
        table.insert(configs, "--enable-tls=" .. tls)
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                name = name:gsub("_", "-")
                if enabled then
                    table.insert(configs, "--enable-" .. name)
                else
                    table.insert(configs, "--disable-" .. name)
                end
            end
        end
        import("package.tools.autoconf").install(package, configs)

        local mflags = {}
        local mxxflags = {}
        local ldflags = {}
        local objfwcfg = path.join(package:installdir("bin"), "objfw-config")
        local mflags_str = os.iorunv(objfwcfg, {"--cflags", "--cppflags", "--objcflags", (package:config("arc") and "--arc" or "")})
        local mxxflags_str = os.iorunv(objfwcfg, {"--cxxflags", "--cppflags", "--objcflags", (package:config("arc") and "--arc" or "")})
        local ldflags_str = os.iorunv(objfwcfg, {"--ldflags"})
        table.join2(mflags, mflags_str:split("%s+"))
        table.join2(mxxflags, mxxflags_str:split("%s+"))
        table.join2(ldflags, ldflags_str:split("%s+"))
        package:add("mflags", mflags)
        package:add("mxxflags", mxxflags)
        package:add("ldflags", ldflags)
    end)

    on_test(function (package)
        assert(package:check_msnippets({test = [[
            #include <stdio.h>
            void test() {
                OFString* string = @"hello";
                printf("%s\n", [string UTF8String]);
            }
        ]]}, {includes = {"ObjFW/ObjFW.h"}}))
    end)
