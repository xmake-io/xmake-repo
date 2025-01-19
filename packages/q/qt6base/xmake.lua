package("qt6base")
    set_kind("phony")
    set_base("qtbase")

    add_versions("6.3.0", "dummy")
    add_versions("6.3.1", "dummy")
    add_versions("6.3.2", "dummy")
    add_versions("6.4.0", "dummy")
    add_versions("6.4.1", "dummy")
    add_versions("6.4.2", "dummy")
    add_versions("6.4.3", "dummy")
    add_versions("6.5.0", "dummy")
    add_versions("6.5.1", "dummy")
    add_versions("6.5.2", "dummy")
    add_versions("6.5.3", "dummy")
    add_versions("6.6.0", "dummy")
    add_versions("6.6.1", "dummy")
    add_versions("6.6.2", "dummy")
    add_versions("6.6.3", "dummy")
    add_versions("6.7.0", "dummy")
    add_versions("6.7.1", "dummy")
    add_versions("6.7.2", "dummy")
    add_versions("6.8.0", "dummy")

    on_install("windows|x64", "linux|x86_64", "macosx", "mingw|x86_64", function (package)
        package:base():script("install")(package)
    end)
