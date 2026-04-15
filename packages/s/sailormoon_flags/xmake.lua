package("sailormoon_flags")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/sailormoon/flags")
    set_description("Simple, extensible, header-only C++17 argument parser released into the public domain.")
    set_license("MIT")

    add_urls("https://github.com/sailormoon/flags/archive/refs/tags/v$(version).tar.gz")
    add_versions("1.2", "2fb981e00d5f97753fa2b685819c4cab8aea7a3f62939a9a0549fb8406b37500")
    add_versions("1.1", "f6626c97ba7a45c473557db2e4b68df4d9cda18a8a97c89a5d8d4e5c53dde904")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndkver = ndk:config("ndkver")
            if package:version() and package:version():ge("1.2") then
                assert(ndkver and tonumber(ndkver) >= 27, "package(sailormoon_flags >= 1.2): need ndk version >= 27")
            end
        end)
    end

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        local languages = "c++17"
        if package:version() and package:version():ge("1.2") then
            languages = "c++20"
        end
        assert(package:check_cxxsnippets({test = [[
            #include "flags.h"
            void test() {
                int argc = 2;
                char **argv = NULL;
                const flags::args args(argc, argv);
            }
        ]]}, {configs = {languages = languages}}))
    end)
