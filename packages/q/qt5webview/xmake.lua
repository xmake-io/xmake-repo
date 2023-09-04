package("qt5webview")
    set_base("qt5lib")
    set_kind("library")

    on_load(function (package)
        package:add("deps", "qt5core", "qt5gui", {debug = package:is_debug(), version = package:version_str()})
        package:data_set("libname", "WebView")

        package:base():script("load")(package)
    end)

    on_install("windows|x86", "windows|x64", "linux", "macosx", "android", "iphoneos", function (package)
        package:base():script("install")(package)
    end)

    on_test(function (package)
        local cxflags
        if not package:is_plat("windows") then
            cxflags = "-fPIC"
        end
        assert(package:check_cxxsnippets({test = [[
            int test(int argc, char** argv) {
                QtWebView::initialize();
                QGuiApplication  app (argc, argv);
                return app.exec();
            }
        ]]}, {configs = {languages = "c++14", cxflags = cxflags}, includes = {"QGuiApplication", "QtWebView"}}))
    end)
