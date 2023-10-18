package("clipboard_lite")
    set_homepage("https://github.com/smasherprog/clipboard_lite")
    set_description("cross platform clipboard library")
    set_license("MIT")

    add_urls("https://github.com/smasherprog/clipboard_lite.git")
    add_versions("2023.10.16", "ffff8f452af0c3587e9789ec40692d519c6170f0")

    if is_plat("windows", "mingw") then
        add_syslinks("user32", "gdi32", "shlwapi")
    elseif is_plat("linux") then
        add_deps("libx11")
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "Cocoa")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <Clipboard_Lite.h>
            void test() {
                auto clipboard = SL::Clipboard_Lite::CreateClipboard();
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
