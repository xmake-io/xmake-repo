package("qt6quick")
    set_base("qt6lib")
    set_kind("library")

    on_load(function (package)
        package:add("deps", "qt6core", "qt6gui", "qt6qml", {debug = package:is_debug(), version = package:version_str()})
        package:data_set("libname", "Quick")

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
            int test(int argc, char** argv) 
            {                
                QGuiApplication app(argc, argv);
                QQuickView view;
                view.setSource(QUrl::fromLocalFile("MyItem.qml"));
                view.show();
                return app.exec();
            }
        ]]}, {configs = {languages = "c++17", cxflags = cxflags}, includes = {"QGuiApplication", "QQuickView"}}))
    end)