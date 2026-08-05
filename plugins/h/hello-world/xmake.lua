package("hello-world")
    set_kind("plugin")
    set_description("Say hello to the world.")

    set_sourcedir(path.join(os.scriptdir(), "plugins"))

    on_test(function (package)
        os.vrun("xmake hello")
        os.vrun("xmake hello -n xmake")
    end)
