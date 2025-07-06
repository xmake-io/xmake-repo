package("curl")
    set_kind("binary")
    set_base("libcurl")

    on_load(function (package)
        package:base():plat_set(package:plat())
        package:base():arch_set(package:arch())
        package:base():script("load")(package)
    end)

    on_install("@windows", "@macosx", "@linux", function (package)
        package:base():script("install")(package)
    end)

    on_test(function (package)
        os.vrun("curl --version")
    end)
