package("qt5widgets")

    set_homepage("https://www.qt.io")
    set_description("Qt is the faster, smarter way to create innovative devices, modern UIs & applications for multiple screens. Cross-platform software development at its best.")
    set_license("LGPL-3")

    add_configs("shared", {description = "Download shared binaries.", default = true, type = "boolean", readonly = true})
    add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})

    add_versions("5.15.2", "dummy")
    add_versions("5.12.5", "dummy")

    on_load(function (package)
        package:add("deps", "qt5base", "qt5core", "qt5gui", {debug = package:is_debug(), version = package:version_str()})
    end)

    on_fetch(function (package)
        local base = package:dep("qt5base")
        local qt = base:data("qtdir")
        if not qt then
            return
        end

        return {
            version = qt.version,
            includedirs = {qt.includedir, path.join(qt.includedir, "QtWidgets")},
            links = table.wrap("Qt5Widgets" .. (package:is_plat("windows") and package:is_debug() and "d" or "")),
            linkdirs = table.wrap(qt.libdir)
        }
    end)

    on_install(function (package)
        local base = package:dep("qt5base")
        local qt = base:data("qtdir")
        assert(qt, "qt5base is required")
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
