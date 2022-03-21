package("qt5base")
    set_kind("phony")
    set_base("qtbase")

    add_versions("5.15.2", "dummy")
    add_versions("5.12.5", "dummy")

    on_load(function (package)
        package:set("kind", "phony")
    end)
