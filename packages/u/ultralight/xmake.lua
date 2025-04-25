package("ultralight")
    set_homepage("https://ultralig.ht")
    set_description("Ultralight makes it easy for C/C++ developers to seamlessly integrate web-content into games and desktop apps.")
    set_license("LGPL")

    if is_plat("windows") then
        if is_arch("x86_64", "x64") then
            add_urls("https://ultralight-sdk.sfo2.cdn.digitaloceanspaces.com/ultralight-sdk-$(version)-win-x64.7z", {alias = "release"})
            add_versions("release:208d653", "4fa7aadd1e4ba4a7dc04d17b1d82b37b141c6e4e7196501150486fa6ac1635c5") -- 2023-07-24T22:00:29.614Z
        end
    elseif is_plat("linux") then
        if is_arch("x86_64", "x64") then
            add_urls("https://ultralight-sdk.sfo2.cdn.digitaloceanspaces.com/ultralight-sdk-$(version)-linux-x64.7z", {alias = "release"})
            add_versions("release:208d653", "1de6298b5ed3c5e0c22ac27e0e30fcb0ba6d195467a58ee44ef4e13dd1a6d352") -- 2023-07-24T22:00:06.347Z
        end
    elseif is_plat("macosx") then
        if is_arch("x86_64", "x64") then
            add_urls("https://ultralight-sdk.sfo2.cdn.digitaloceanspaces.com/ultralight-sdk-$(version)-mac-x64.7z", {alias = "release"})
            add_versions("release:208d653", "bbf81ed456a617a60a19e9a76946e4479d5bac877f859005c50f66e9ec3c77a2") -- 2023-07-24T21:59:44.717Z
        end
    end

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    on_install("windows|x64", "linux|x86_64", "macosx|x86_64", function (package)
        os.cp("include", package:installdir())
        os.trycp("bin/*.dll", package:installdir("bin"))
        os.trycp("lib/*.lib", package:installdir("lib"))
        os.trycp("bin/*.so", package:installdir("lib"))
        os.trycp("bin/*.dylib", package:installdir("lib"))
    end)

    on_test(function (package)
         assert(package:check_cxxsnippets({test = [[
            #include <AppCore/App.h>
            #include <Ultralight/platform/Platform.h>
            void test()
            {
                auto app = ultralight::App::Create();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)