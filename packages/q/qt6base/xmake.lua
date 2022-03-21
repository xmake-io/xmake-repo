package("qt6base")
    set_kind("phony")
    set_base("qtbase")

    add_versions("6.3.0", "dummy")

    on_load(function (package)
        package:set("kind", "phony")
    end)
