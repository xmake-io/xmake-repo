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

    on_install("linux", "macosx", function (package)
        local configs = {"--without-tls"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
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
