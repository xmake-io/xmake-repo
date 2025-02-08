package("libsdl_net")
    set_base("libsdl2_net")

    add_deps("cmake")

    on_load(function (package)
        wprint("libsdl_net package has been renamed to libsdl2_net following the release of SDL3, please update the package name in your xmake.lua.${clear}")
        package:base():script("load")(package)
    end)
