package("qt5gui")
    set_base("qt5lib")
    set_kind("library")

    on_load(function (package)
        package:add("deps", "qt5core", {debug = package:is_debug(), version = package:version_str()})
        package:data_set("libname", "Gui")

        if package:is_plat("android") then
            package:data_set("syslinks", "GLESv2")
        elseif package:is_plat("iphoneos") then
            package:data_set("links", "qtharfbuzz")
            package:data_set("syslinks", {"qtlibpng", "z"})
        end

        package:base():script("load")(package)
        package:set("kind", "library")
    end)

    on_test(function (package)
        local cxflags
        if not package:is_plat("windows") then
            cxflags = "-fPIC"
        end
        assert(package:check_cxxsnippets({test = [[
            int test(int argc, char** argv) {
                QGuiApplication app (argc, argv);
                return app.exec();
            }
        ]]}, {configs = {languages = "c++14", cxflags = cxflags}, includes = {"QGuiApplication"}}))
    end)
