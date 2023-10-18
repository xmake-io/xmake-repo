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

    on_install("windows", "linux", "macosx", "mingw", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            if is_plat("linux") then
                add_requires("libx11")
            end
            set_languages("c++14")
            target("clipboard_lite")
                set_kind("$(kind)")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end

                add_files("src/*.cpp")
                add_includedirs("include")
                add_headerfiles("include/Clipboard_Lite.h")
                if is_plat("windows", "mingw") then
                    add_files("src/windows/*.cpp")
                    add_includedirs("include/windows")
                    add_syslinks("user32", "gdi32", "shlwapi")
                elseif is_plat("linux") then
                    add_files("src/linux/*.cpp")
                    add_includedirs("include/linux")
                    add_syslinks("pthread")
                    add_packages("libx11")
                elseif is_plat("macosx") then
                    add_files("src/ios/*.mm")
                    add_includedirs("include/ios")
                    add_frameworks("CoreFoundation", "Cocoa")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <Clipboard_Lite.h>
            void test() {
                auto clipboard = SL::Clipboard_Lite::CreateClipboard();
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
