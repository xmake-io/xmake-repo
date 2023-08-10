package("qt6widgets")
    set_base("qt6lib")
    set_kind("library")

    on_load(function (package)
        package:add("deps", "qt6core", "qt6gui", {debug = package:is_debug(), version = package:version_str()})
        package:data_set("libname", "Widgets")

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
                QApplication app (argc, argv);
                QPushButton button ("Hello world !");
                button.show();
                return app.exec();
            }
        ]]}, {configs = {languages = "c++17", cxflags = cxflags}, includes = {"QApplication", "QPushButton"}}))
    end)
