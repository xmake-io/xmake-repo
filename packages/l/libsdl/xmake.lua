package("libsdl")
    set_base("libsdl2")

    add_deps("cmake")

    on_load(function (package)
        wprint("libsdl package has been renamed to libsdl2 following the release of SDL3 which is also available under the name libsdl3.${clear}")
        package:base():script("load")(package)
    end)
