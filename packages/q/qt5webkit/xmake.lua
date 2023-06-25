package("qt5webkit")
    set_base("qt5lib")
    set_kind("library")

    on_load(function (package)
        package:add("deps", "qt5core", "qt5gui", {debug = package:is_debug(), version = package:version_str()})
        package:data_set("libname", "WebKit")

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
                QtWebView::initialize();
                QApplication app (argc, argv);
                return app.exec();
            }
        ]]}, {configs = {languages = "c++14", cxflags = cxflags}, includes = {"QApplication", "QWebView"}}))
    end)
