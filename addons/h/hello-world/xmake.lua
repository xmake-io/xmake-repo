package("hello-world")
    set_kind("addon")
    set_description("Say hello to the world.")

    set_sourcedir(path.join(os.scriptdir(), "addon"))

    on_test(function (package)
        assert(package:has_addon({plugins = "hello"}))
        os.vrun("xmake hello")
        os.vrun("xmake hello -n xmake")
    end)
