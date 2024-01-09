package("ultralight")
    set_homepage("https://ultralig.ht")
    set_description("Ultralight makes it easy for C/C++ developers to seamlessly integrate web-content into games and desktop apps.")
    set_license("LGPL")

    if (is_plat("windows")) then
        add_urls("https://github.com/ultralight-ux/Ultralight/releases/download/v$(version)/ultralight-sdk-$(version)-win-$(arch)-dbg.7z")
    else
        add_urls("https://github.com/ultralight-ux/Ultralight/releases/download/v$(version)/ultralight-sdk-$(version)-$(plat)-$(arch).7z")
    end

    add_versions("1.3.0", "cc8bfc66a4c40c88fa02691febe6f21c248a2a30d17cfe5470fccc3a461ce49e")

    on_install("windows", "linux", "macosx", function (package)
        os.cp("include", package:installdir())
        os.cp("lib", package:installdir())
        os.cp("bin", package:installdir())
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

package_end()