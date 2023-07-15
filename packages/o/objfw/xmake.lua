package("objfw-local")
    set_homepage("https://objfw.nil.im")
    set_description("[Official Mirror] A portable framework for the Objective-C language.")

    add_urls("https://github.com/ObjFW/ObjFW.git")
    add_versions("2023.03.18", "86cec7d17dd323407f30fc5947e0e92cc307e869")

    add_deps("autoconf", "automake", "libtool")

    if is_plat("macosx") then
        add_syslinks("objc")
        add_frameworks("CoreFoundation")
    end

    add_configs("tls", {
        description = "Enable TLS support.",
        default = true,
        type = "boolean"
    })

    add_configs("arc", {
        description = "Enable Automatic Reference Counting (ARC) support.",
        default = true,
        type = "boolean"
    })

    on_install("linux", "macosx", "cygwin", function (package)
        local configs = {}
        table.insert(configs, (package:config("tls") and "" or "--without-tls"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)

        local tool = import("lib.detect.find_tool")

        --use the built objfw-config
        local objfwcfg = tool("objfw-config")
        print("Found objfwconfig: ", objfwcfg)

        local objcflags = os.iorunv(objfwcfg.program, { "--objcflags", (package:config("arc") and "--arc" or "") })
        local ldflags = os.iorunv(objfwcfg.program, { "--ldflags" })

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
