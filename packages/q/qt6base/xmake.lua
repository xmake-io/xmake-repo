package("qt6base")
    set_kind("phony")
    set_base("qtbase")

    add_versions("6.3.0", "dummy")
    add_versions("6.5.1", "dummy")
    add_versions("6.6.0", "dummy")

    on_install("windows|x64", "linux|x86_64", "macosx|x86_64", "mingw|x86_64", function (package)
        package:base():script("install")(package)
    end)
