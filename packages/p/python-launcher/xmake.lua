package("python-launcher")

    set_kind("binary")
    set_homepage("https://www.python.org/")
    set_description("The python programming language.")

    if is_arch("x86", "i386") or os.arch() == "x86" then
        add_urls("https://github.com/xmake-mirror/python-windows/releases/download/$(version)/python-launcher-$(version).win32.zip")
        add_versions("3.9.6", "73d712aaca09d7ada78bcf26dfc3346f655b4b1fed5b459133ce564b9c5f5663")
    else
        add_urls("https://github.com/xmake-mirror/python-windows/releases/download/$(version)/python-launcher-$(version).win64.zip")
        add_versions("3.9.6", "fc2a54f47f07a193265cb844c0e1b165682c71a1655e92eb3c44f25bacc84b8a")
    end

    on_install("@windows", "@msys", "@cygwin", function (package)
        os.cp("*", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("py -0p")
    end)
