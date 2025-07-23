package("libsdl_mixer")
    set_base("libsdl2_mixer")

    add_deps("cmake")

    on_load(function (package)
        wprint("libsdl_mixer package has been renamed to libsdl2_mixer following the release of SDL3, please update the package name in your xmake.lua.${clear}")
        package:base():script("load")(package)
    end)
