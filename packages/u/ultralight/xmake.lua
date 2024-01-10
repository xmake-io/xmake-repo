package("ultralight")
    set_homepage("https://ultralig.ht")
    set_description("Ultralight makes it easy for C/C++ developers to seamlessly integrate web-content into games and desktop apps.")
    set_license("LGPL")

    if is_plat("windows") then
        add_urls("https://github.com/ultralight-ux/Ultralight/releases/download/v1.3.0/ultralight-sdk-1.3.0-win-x64.7z")
        add_versions("1.3.0", "cc8bfc66a4c40c88fa02691febe6f21c248a2a30d17cfe5470fccc3a461ce49e")
    elseif is_plat("linux") then
        add_urls("https://github.com/ultralight-ux/Ultralight/releases/download/v1.3.0/ultralight-sdk-1.3.0-linux-x64.7z")
        add_versions("1.3.0", "1de6298b5ed3c5e0c22ac27e0e30fcb0ba6d195467a58ee44ef4e13dd1a6d352")
    elseif is_plat("macosx") then
        add_urls("https://github.com/ultralight-ux/Ultralight/releases/download/v1.3.0/ultralight-sdk-1.3.0-mac-x64.7z")
        add_versions("1.3.0", "bbf81ed456a617a60a19e9a76946e4479d5bac877f859005c50f66e9ec3c77a2")
    end

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    on_install("windows|x64", "linux|x86_64", "macosx|x86_64", function (package)
        if linuxos.name() ~= "ubuntu" and linuxos.name() ~= "debian" or (linuxos.version():major() < 9 and linuxos.version():minor() < 5) then
            print("Ultralight is officially supported on Ubuntu/Debian 9.5+. use it at your own risks")
        end
        os.cp("include", package:installdir())
        if package:is_plat("macos") == false then
            os.cp("lib", package:installdir())
            os.cp("bin", package:installdir())
        end
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
