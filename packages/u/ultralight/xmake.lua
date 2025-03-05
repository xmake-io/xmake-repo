package("ultralight")
    set_homepage("https://ultralig.ht")
    set_description("Ultralight makes it easy for C/C++ developers to seamlessly integrate web-content into games and desktop apps.")
    set_license("LGPL")

    if is_plat("windows") then
        add_urls("https://github.com/ultralight-ux/Ultralight/releases/download/v$(version)", {version = function(version)
            if version:endswith("beta") then
                return version .. "/ultralight-sdk-" .. version:sub(1, -6) .. "b-win-x64.7z"
            else
                return version .. "/ultralight-sdk-" .. version .. "-win-x64.7z"
            end
        end})
        add_versions("1.3.0", "cc8bfc66a4c40c88fa02691febe6f21c248a2a30d17cfe5470fccc3a461ce49e")
        add_versions("1.4.0-beta", "6749c3d1aef49ba1c4ca783a453fe2f68b827b5935534751b68623b4b0eb91f1")
    elseif is_plat("linux") then
        if os.arch() == "arm64" then
            add_urls("https://github.com/ultralight-ux/Ultralight/releases/download/v$(version)/ultralight-sdk-$(version)-linux-arm64.7z", {version = function(version)
                if version:endswith("beta") then
                    return version .. "/ultralight-sdk-" .. version:sub(1, -6) .. "b-linux-arm64.7z"
                else
                    return version .. "/ultralight-sdk-" .. version .. "-linux-arm64.7z"
                end
            end})
            add_versions("1.4.0-beta", "efa8f6c8b351daa42570f11bcb162f280cca2ce8e167f854a5e0687db854f268")
        else
            add_urls("https://github.com/ultralight-ux/Ultralight/releases/download/v$(version)/ultralight-sdk-$(version)-linux-x64.7z", {version = function(version)
                if version:endswith("beta") then
                    return version .. "/ultralight-sdk-" .. version:sub(1, -6) .. "b-linux-x64.7z"
                else
                    return version .. "/ultralight-sdk-" .. version .. "-linux-x64.7z"
                end
            end})
            add_versions("1.3.0", "1de6298b5ed3c5e0c22ac27e0e30fcb0ba6d195467a58ee44ef4e13dd1a6d352")
            add_versions("1.4.0-beta", "1a72c567f2a33b5d6f7ba2cb253d39a78730bbe316ee5649e5e697e0e4b6ca1b")
        end
    elseif is_host("macosx") then
        if os.arch() == "arm64" then
            add_urls("https://github.com/ultralight-ux/Ultralight/releases/download/v$(version)/ultralight-sdk-$(version)-mac-x64.7z", {version = function(version)
                if version:endswith("beta") then
                    return version .. "/ultralight-sdk-" .. version:sub(1, -6) .. "b-mac-x64.7z"
                else
                    return version .. "/ultralight-sdk-" .. version .. "-mac-x64.7z"
                end
            end})
            add_versions("1.4.0-beta", "3b8c71cf8e403738dcdb12cacc233838c168d48322c31d40ec1c6fcaa761a016")
        else
            add_urls("https://github.com/ultralight-ux/Ultralight/releases/download/v$(version)/ultralight-sdk-$(version)-mac-x64.7z", {version = function(version)
                if version:endswith("beta") then
                    return version .. "/ultralight-sdk-" .. version:sub(1, -6) .. "b-mac-x64.7z"
                else
                    return version .. "/ultralight-sdk-" .. version .. "-mac-x64.7z"
                end
            end})
            add_versions("1.3.0", "bbf81ed456a617a60a19e9a76946e4479d5bac877f859005c50f66e9ec3c77a2")
            add_versions("1.4.0-beta", "ac2abd395a5080d35d36a482b7c8e2f4e7bb89bfb6705d35ec07d9dcb4528fa7")
        end
    end

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    on_install("windows|x64", "linux", "macosx", function (package)
        if package:is_plat("linux") then
            if linuxos.name() ~= "ubuntu" and linuxos.name() ~= "debian" or (linuxos.version():major() < 9 and linuxos.version():minor() < 5) then
                print("Ultralight is officially supported on Ubuntu/Debian 9.5+. use it at your own risks")
            end
        end
        os.cp("include", package:installdir())
        os.trycp("lib", package:installdir())
        os.trycp("bin", package:installdir())
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