package("curl")
    set_kind("binary")
    set_base("libcurl")

    on_install("@windows", "@macosx", "@linux", function (package)
        package:base():script("install")(package)
    end)

    on_test(function (package)
        os.vrun("curl --version")
    end)
