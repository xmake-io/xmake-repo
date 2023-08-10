package("qt6gui")
    set_base("qt6lib")
    set_kind("library")

    on_load(function (package)
        package:add("deps", "qt6core", {debug = package:is_debug(), version = package:version_str()})
        package:data_set("libname", "Gui")

        if package:is_plat("linux") then 
            package:add("deps", "freetype", "fontconfig", "libxkbcommon")
        elseif package:is_plat("android") then
            package:data_set("syslinks", "GLESv2")
        elseif package:is_plat("iphoneos") then
            package:data_set("links", "qtharfbuzz")
            package:data_set("syslinks", {"qtlibpng", "z"})
        end
    
        package:base():script("load")(package)
    end)

    on_test(function (package)
        local cxflags
        if package:is_plat("windows") then
            cxflags = {"/Zc:__cplusplus", "/permissive-"}
        else
            cxflags = "-fPIC"
        end
        assert(package:check_cxxsnippets({test = [[
            int test(int argc, char** argv) {
                QGuiApplication app (argc, argv);
                return app.exec();
            }
        ]]}, {configs = {languages = "c++17", cxflags = cxflags}, includes = {"QGuiApplication"}}))
    end)
