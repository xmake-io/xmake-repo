package("qt5base")
    set_kind("phony")
    set_base("qtbase")

    add_versions("5.15.2", "dummy")
    add_versions("5.12.5", "dummy")

    on_install("windows|x86", "windows|x64", "linux", "macosx", "mingw", "android", "iphoneos", function (package, opt)
        package:base():script("install")(package, opt)
    end)
