package("ultralight")
    set_homepage("https://ultralig.ht")
    set_description("Ultralight makes it easy for C/C++ developers to seamlessly integrate web-content into games and desktop apps.")
    set_license("LGPL")

    local versions = {
        ["1.3.0"] = "208d653"
    }

    if is_plat("windows") then
        if is_arch("x86_64", "x64") then
            add_urls("https://ultralight-sdk.sfo2.cdn.digitaloceanspaces.com/ultralight-sdk-$(version)-win-x64.7z", {alias = "release", version = function (version)
                return versions[tostring(version)]
            end})
            add_versions("release:1.3.0", "4fa7aadd1e4ba4a7dc04d17b1d82b37b141c6e4e7196501150486fa6ac1635c5")
            add_urls("https://github.com/xmake-mirror/Ultralight/releases/download/$(version)", {alias = "mirror", version = function (version)
                local beta_version, count =  version:gsub("-beta$", "b")
                if count ~= 1 then
                    return version .. "/ultralight-free-sdk-" .. beta_version .. "-win-x64.7z"
                else
                    return version .. "/ultralight-sdk-" .. beta_version .. "-win-x64.7z"
                end
            end})
            add_versions("mirror:1.4.0-beta", "6749c3d1aef49ba1c4ca783a453fe2f68b827b5935534751b68623b4b0eb91f1")
            add_versions("mirror:1.4.0", "136d5d166da07b2029d915cc3c809288e56dd0bce0f0e54c5102f3ed16ce385a")
        end
    elseif is_plat("linux") then
        if is_arch("x86_64", "x64") then
            add_urls("https://ultralight-sdk.sfo2.cdn.digitaloceanspaces.com/ultralight-sdk-$(version)-linux-x64.7z", {alias = "release", version = function (version)
                return versions[tostring(version)]
            end})
            add_versions("release:1.3.0", "1de6298b5ed3c5e0c22ac27e0e30fcb0ba6d195467a58ee44ef4e13dd1a6d352")
            add_urls("https://github.com/xmake-mirror/Ultralight/releases/download/$(version)", {alias = "mirror", version = function (version)
                local beta_version, count =  version:gsub("-beta$", "b")
                if count ~= 1 then
                    return version .. "/ultralight-free-sdk-" .. beta_version .. "-linux-x64.7z"
                else
                    return version .. "/ultralight-sdk-" .. beta_version .. "-linux-x64.7z"
                end
            end})
            add_versions("mirror:1.4.0-beta", "1d5092bfd7d96417547872a5c5b5950207f495ea299d713fa105314f4185c760")
            add_versions("mirror:1.4.0", "75e3079a9bcae834e98607af0d8ec6ef8f8144abc674ce961cf878fb2d816ddd")
        else
            add_urls("https://github.com/xmake-mirror/Ultralight/releases/download/$(version)", {alias = "mirror", version = function (version)
                local beta_version, count =  version:gsub("-beta$", "b")
                if count ~= 1 then
                    return version .. "/ultralight-free-sdk-" .. beta_version .. "-linux-arm64.7z"
                else
                    return version .. "/ultralight-sdk-" .. beta_version .. "-linux-arm64.7z"
                end
            end})
            add_versions("mirror:1.4.0-beta", "efa8f6c8b351daa42570f11bcb162f280cca2ce8e167f854a5e0687db854f268")
            add_versions("mirror:1.4.0", "7c577948493f52d7f647d3fd5fde6bee8c102b0448c74c460ccf695eab01a742")
        end
    elseif is_plat("macosx") then
        if is_arch("x86_64", "x64") then
            add_urls("https://ultralight-sdk.sfo2.cdn.digitaloceanspaces.com/ultralight-sdk-$(version)-mac-x64.7z", {alias = "release", version = function (version)
                return versions[tostring(version)]
            end})
            add_versions("release:1.3.0", "bbf81ed456a617a60a19e9a76946e4479d5bac877f859005c50f66e9ec3c77a2")
            add_urls("https://github.com/xmake-mirror/Ultralight/releases/download/$(version)", {alias = "mirror", version = function (version)
                local beta_version, count =  version:gsub("-beta$", "b")
                if count ~= 1 then
                    return version .. "/ultralight-free-sdk-" .. beta_version .. "-mac-x64.7z"
                else
                    return version .. "/ultralight-sdk-" .. beta_version .. "-mac-x64.7z"
                end
            end})
            add_versions("mirror:1.4.0-beta", "ac2abd395a5080d35d36a482b7c8e2f4e7bb89bfb6705d35ec07d9dcb4528fa7")
            add_versions("mirror:1.4.0", "96c6fa7ad6ae46254fc13633cd04d1684f900028831666bea2f1b1618c12f87f")
        else
            add_urls("https://github.com/xmake-mirror/Ultralight/releases/download/$(version)", {alias = "mirror", version = function (version)
                local beta_version, count =  version:gsub("-beta$", "b")
                if count ~= 1 then
                    return version .. "/ultralight-free-sdk-" .. beta_version .. "-mac-arm64.7z"
                else
                    return version .. "/ultralight-sdk-" .. beta_version .. "-mac-arm64.7z"
                end
            end})
            add_versions("mirror:1.4.0-beta", "3b8c71cf8e403738dcdb12cacc233838c168d48322c31d40ec1c6fcaa761a016")
            add_versions("mirror:1.4.0", "8f9b46a83d9fdeca5a9f67b7c7e59f1dbdcf3bb78d38a645ad33678199b4d9e7")
        end
    end

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    if is_plat("linux") then
        add_deps("fontconfig")
    end

    on_check(function (package)
        if package:version():gt("1.3.0") then
            if package:is_plat("linux") then
                local distrib = linuxos.name()
                assert(distrib ~= "archlinux", "package(ultralight): Archlinux is not supported.")
                assert(distrib ~= "fedora", "package(ultralight): Fedora is not supported.")
            end
        else
            assert(not package:is_arch("arm.*"), "package(ultralight): version older than 1.4.0 does not support arm.")
        end
        assert(not package:is_arch("x86", "i386", "i686"), "package(ultralight): does not support x86/i386/i686.")
    end)

    on_install("windows|!arm*", "linux", "macosx", function (package)
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
