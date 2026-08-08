package("hello-world")
    set_kind("addon")
    set_description("Say hello to the world.")

    set_sourcedir(os.scriptdir())

    on_test(function (package)
        os.vrun("xmake hello")
        os.vrun("xmake hello -n xmake")
    end)
