package("qtawesome")
    set_homepage("https://github.com/gamecreature/QtAwesome")
    set_description("QtAwesome - Font Awesome for Qt Applications")
    set_license("MIT")

    add_urls("https://github.com/gamecreature/QtAwesome/archive/refs/tags/font-awesome-$(version).tar.gz",
             "https://github.com/gamecreature/QtAwesome.git")

    add_versions("6.4.2", "4a1d68ce77c67e35ce6ab9b54c6e093fe3e783123513312d954e093bc950f250")

    add_configs("pro", {description = "Use pro version", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    add_deps("qt6core", "qt6widgets")

    on_install("windows|x64", "linux|x86_64", "macosx|x86_64", "mingw|x86_64",function (package)
        io.writefile("xmake.lua", [[
            option("pro", {showmenu = true, default = false})
            add_rules("mode.debug", "mode.release")
            add_requires("qt6core", "qt6widgets")
            target("qtawesome")
                add_rules("qt.$(kind)")
                add_files("QtAwesome/*.cpp", "QtAwesome/*.h")
                if has_config("pro") then
                    add_files("QtAwesome/QtAwesomePro.qrc")
                else
                    add_files("QtAwesome/QtAwesomeFree.qrc")
                end
                add_headerfiles("(QtAwesome/*.h)")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
                add_packages("qt6core", "qt6widgets")
        ]])
        import("package.tools.xmake").install(package, {pro = package:config("pro")})
    end)

    on_test(function (package)
        local cxflags
        if package:is_plat("windows") then
            cxflags = {"/Zc:__cplusplus", "/permissive-"}
        else
            cxflags = "-fPIC"
        end
        assert(package:check_cxxsnippets({test = [[
            #include <QtAwesome/QtAwesome.h>
            void test() {
                fa::QtAwesome* awesome = new fa::QtAwesome(nullptr);
                awesome->initFontAwesome();
            }
        ]]}, {configs = {languages = "c++17", cxflags = cxflags}}))
    end)
