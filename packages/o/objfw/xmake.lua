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
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))

        table.insert(configs, "--disable-threads=" .. (package:config("threads") and "no" or "yes"))
        table.insert(configs, "--disable-compiler-tls=" .. (package:config("compiler-tls") and "no" or "yes"))
        table.insert(configs, "--disable-files=" .. (package:config("files") and "no" or "yes"))
        table.insert(configs, "--disable-sockets=" .. (package:config("sockets") and "no" or "yes"))

        table.insert(configs, "--disable-codepage-437=" .. (package:config("codepage-437") and "no" or "yes"))
        table.insert(configs, "--disable-codepage-850=" .. (package:config("codepage-850") and "no" or "yes"))
        table.insert(configs, "--disable-codepage-858=" .. (package:config("codepage-858") and "no" or "yes"))
        table.insert(configs, "--disable-iso-8859-2=" .. (package:config("iso-8859-2") and "no" or "yes"))
        table.insert(configs, "--disable-iso-8859-3=" .. (package:config("iso-8859-3") and "no" or "yes"))
        table.insert(configs, "--disable-iso-8859-15=" .. (package:config("iso-8859-15") and "no" or "yes"))
        table.insert(configs, "--disable-koi8-r=" .. (package:config("koi8-r") and "no" or "yes"))
        table.insert(configs, "--disable-koi8-u=" .. (package:config("koi8-u") and "no" or "yes"))
        table.insert(configs, "--disable-mac-roman=" .. (package:config("mac-roman") and "no" or "yes"))
        table.insert(configs, "--disable-windows-1251=" .. (package:config("windows-1251") and "no" or "yes"))
        table.insert(configs, "--disable-windows-1252=" .. (package:config("windows-1252") and "no" or "yes"))

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
