package("libtask")

    set_homepage("https://swtch.com/libtask/")
    set_description("a Coroutine Library for C and Unix")

    set_urls("https://swtch.com/libtask.tar.gz")

    add_versions("1.0", "4f484fbb29f8d016fa9f12a7c89abd9b0972cb677319369b076ec1558db7c327")

    on_build("macosx", "linux", function (package)
        os.vrun("make")
    end)

    on_install("macosx", "linux", function (package)
        os.cp("*.h", package:installdir("include"))
        os.cp("libtask.a", package:installdir("lib"))
    end)

