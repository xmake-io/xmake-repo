package("qt5widgets")
    set_base("qt5lib")
    set_kind("library")

    on_load(function (package)
        package:add("deps", "qt5core", "qt5gui", {debug = package:is_debug(), version = package:version_str()})
        package:data_set("libname", "Widgets")

        package:base():script("load")(package)
    end)

    on_test(function (package)
        local cxflags
        if not package:is_plat("windows") then
            cxflags = "-fPIC"
        end
        assert(package:check_cxxsnippets({test = [[
            int test(int argc, char** argv) {
                QApplication app (argc, argv);
                QPushButton button ("Hello world !");
                button.show();
                return app.exec();
            }
        ]]}, {configs = {languages = "c++14", cxflags = cxflags}, includes = {"QApplication", "QPushButton"}}))
    end)
