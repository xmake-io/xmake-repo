package("qt5widgets")
    set_base("qt5lib")
    set_kind("library")

    on_load(function (package)
        package:add("deps", "qt5base", "qt5core", "qt5gui", {debug = package:is_debug(), version = package:version_str()})
        package:data_set("libname", "Widgets")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            int test(int argc, char** argv) {
                QApplication app (argc, argv);
                QPushButton button ("Hello world !");
                button.show();
                return app.exec();
            }
        ]]}, {configs = {languages = "c++14", cxflags = not package:is_plat("windows") and "-fPIC" or nil}, includes = {"QApplication", "QPushButton"}}))
    end)
