package("godotheaders")

    set_homepage("https://godotengine.org")
    set_description("Headers for the Godot API supplied by the GDNative module")

    set_urls("https://github.com/godotengine/godot-headers/archive/godot-$(version)-stable.zip")
    add_versions("3.2.3", "91815415a134ec061e1126a78d773bb13b28417f6dff34e02d54a38bf1b7e27d")

    on_install(function (package)
        os.cp("android",      package:installdir("include"))
        os.cp("arvr",         package:installdir("include"))
        os.cp("gdnative",     package:installdir("include"))
        os.cp("nativescript", package:installdir("include"))
        os.cp("net",          package:installdir("include"))
        os.cp("pluginscript", package:installdir("include"))
        os.cp("videodecoder", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("godot_nativescript_register_class", {includes = "nativescript/godot_nativescript.h"}))
        assert(package:has_cfuncs("godot_print",                       {includes = "gdnative/gdnative.h"}))
    end)