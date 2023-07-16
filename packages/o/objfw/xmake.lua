package("objfw")
    set_homepage("https://objfw.nil.im")
    set_description("[Official Mirror] A portable framework for the Objective-C language.")

    add_urls("https://github.com/ObjFW/ObjFW.git")
    add_versions("2023.03.18", "86cec7d17dd323407f30fc5947e0e92cc307e869")

    add_deps("autoconf", "automake", "libtool")

    if is_plat("macosx") then
        add_syslinks("objc")
        add_frameworks("CoreFoundation")
    end

    add_configs("tls", { description = "Enable TLS support.", default = true, type = "boolean" })
    add_configs("seluid24", { description = "Use 24 bit instead of 16 but for selector UIDs.", default = true, type = "boolean" })

    add_configs("codepage-437", { description = "Enable codepage 437 support.", default = true, type = "boolean" })
    add_configs("codepage-850", { description = "Enable codepage 850 support.", default = true, type = "boolean" })
    add_configs("codepage-858", { description = "Enable codepage 858 support.", default = true, type = "boolean" })
    add_configs("iso-8859-2", { description = "Enable ISO-8859-2 support.", default = true, type = "boolean" })
    add_configs("iso-8859-3", { description = "Enable ISO-8859-3 support.", default = true, type = "boolean" })
    add_configs("iso-8859-15", { description = "Enable ISO-8859-15 support.", default = true, type = "boolean" })
    add_configs("koi8-r", { description = "Enable KOI8-R support.", default = true, type = "boolean" })
    add_configs("koi8-u", { description = "Enable KOI8-U support.", default = true, type = "boolean" })
    add_configs("mac-roman", { description = "Enable Mac Roman encoding support.", default = true, type = "boolean" })
    add_configs("windows-1251", { description = "Enable windows 1251 support.", default = true, type = "boolean" })
    add_configs("windows-1252", { description = "Enable windows 1252 support.", default = true, type = "boolean" })

    add_configs("threads", { description = "Enable threads.", default = true, type = "boolean" })
    add_configs("compiler-tls", { description = "Enable compiler thread local storage (TLS).", default = true, type = "boolean" })
    add_configs("files", { description = "Enable files.", default = true, type = "boolean" })
    add_configs("sockets", { description = "Enable sockets.", default = true, type = "boolean" })

    add_configs("arc", { description = "Enable Automatic Reference Counting (ARC) support.", default = true, type = "boolean" })

    on_install("linux", "macosx", "cygwin", function (package)
        local configs = {}
        table.insert(configs, (package:config("tls") and "" or "--without-tls"))

        local function config(cfg)
            if package:config(cfg) then
                table.insert(configs, "--enable-" .. cfg)
            else
                table.insert(configs, "--disable-" .. cfg)
            end
        end

        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))

        config("threads")
        config("compiler-tls")
        config("files")
        config("sockets")

        config("codepage-437")
        config("codepage-858")
        config("codepage-850")
        config("iso-8859-3")
        config("iso-8859-2")
        config("koi8-r")
        config("koi8-u")
        config("iso-8859-15")
        config("mac-roman")
        config("windows-1251")
        config("windows-1252")

        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)

        local objfwcfg = import("lib.detect.find_tool")("objfw-config", { paths = { package:installdir("bin") } }).program

        local objcflags_str = os.iorunv(objfwcfg, { "--objcflags", (package:config("arc") and "--arc" or "") })
        local ldflags_str = os.iorunv(objfwcfg, { "--ldflags" })

        local objcflags = {}
        local ldflags = {}

        for flag in objcflags_str:gmatch("%S+") do
            table.insert(objcflags, flag)
        end

        for flag in ldflags_str:gmatch("%S+") do
            table.insert(ldflags, flag)
        end

        package:add("mflags", objcflags)
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
