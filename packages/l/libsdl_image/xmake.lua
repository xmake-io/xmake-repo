package("libsdl_image")
    set_base("libsdl2_image")

    add_deps("cmake")

    on_load(function (package)
        wprint("libsdl_image package has been renamed to libsdl2_image following the release of SDL3, please update the package name in your xmake.lua.${clear}")
        package:base():script("load")(package)
    end)
