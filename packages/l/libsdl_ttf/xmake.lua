package("libsdl_ttf")
    set_base("libsdl2_ttf")

    add_deps("cmake", "freetype")

    on_load(function (package)
        wprint("libsdl_ttf package has been renamed to libsdl2_ttf following the release of SDL3, please update the package name in your xmake.lua.${clear}")
        package:base():script("load")(package)
    end)
