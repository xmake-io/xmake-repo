package("qjson")
    set_homepage("http://qjson.sourceforge.net")
    set_description("QJson is a qt-based library that maps JSON data to QVariant objects.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/flavio/qjson.git")
    add_versions("2025.03.13", "d2731237ba0a4176be2483fed79bbd8c451671e4")

    add_deps("cmake")
    add_deps("qt5core", "qt5widgets")

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "QJSON_STATIC")
        end
    end)

    on_install("windows|x86", "windows|x64", function (package)
        io.replace("CMakeLists.txt", [[set(QT4_BUILD ${QT4_BUILD_DEFAULT})]], [[set(QT4_BUILD 0)]], {plain = true})
        io.replace("CMakeLists.txt", [[FIND_PACKAGE( Qt5 COMPONENTS Widgets REQUIRED QUIET )]], [[FIND_PACKAGE( Qt5 COMPONENTS Widgets REQUIRED )]], {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = {"qt5core", "qt5widgets"}})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <QByteArray>
            #include <QVariant>
            #include <qjson-qt5/parser.h>
            void test() {
                QJson::Parser parser;
                QByteArray data;
                bool ok;
                QVariantMap result = parser.parse(data, &ok).toMap();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
