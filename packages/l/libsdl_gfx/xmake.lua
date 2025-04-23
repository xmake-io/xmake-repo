package("libsdl_gfx")
    set_base("libsdl2_gfx")

    add_deps("cmake")

    on_load(function (package)
        wprint("libsdl_gfx package has been renamed to libsdl2_gfx following the release of SDL3, please update the package name in your xmake.lua.${clear}")
        package:base():script("load")(package)
    end)
