package("python-launcher")

    set_kind("binary")
    set_homepage("https://www.python.org/")
    set_description("The python programming language.")

    if is_arch("x86", "i386") or os.arch() == "x86" then
        add_urls("https://github.com/xmake-mirror/python-windows/releases/download/$(version)/python-launcher-$(version).win32.zip")
        add_versions("3.9.6", "73d712aaca09d7ada78bcf26dfc3346f655b4b1fed5b459133ce564b9c5f5663")
        add_versions("3.9.10", "36f445e1569f4b0647080c7603c9a5f635f131b7f2ee5bf29d6c02e38d235b34")
        add_versions("3.9.13", "428178d0270d030b83107ddae33c614355e05af646cca832b3e27cee869412cf")
        add_versions("3.10.6", "e5b53686c903e638166cff54e3e029992c80cd41ad892c9929bd6cee492d64f4")
        add_versions("3.11.3", "9d80b7f39286c297a7871e63867c99cb3d5dea98863d20c51802f2900a1a909d")
        add_versions("3.12.8", "82365526eff7aa340feefc75a0546bee52c0b8494f0722f4cbe0541e1396cdf8")
        add_versions("3.13.1", "cc166fddd76c2c826f2bb29e65fc7a0c5280341733a543bc9bff9211fa53d696")
    else
        add_urls("https://github.com/xmake-mirror/python-windows/releases/download/$(version)/python-launcher-$(version).win64.zip")
        add_versions("3.9.6", "fc2a54f47f07a193265cb844c0e1b165682c71a1655e92eb3c44f25bacc84b8a")
        add_versions("3.9.10", "70df88a455fe2c87c62c0817decb7f54f198ff31ade093ce4d8ecc8cfd452b3f")
        add_versions("3.9.13", "2f99ffa9c34a0df35bd836bd868ba9bbd4e9cf8001f4fb071e995258d80af386")
        add_versions("3.10.6", "68616e070889b3bb82176ff72aea5b760cda636bd6e30d10bad9399dc0a2d0a0")
        add_versions("3.11.3", "afb50e1925f392ddc8917ca0552f108919add6c28bfe13c3a1b610b2ab005ef4")
        add_versions("3.12.8", "44f21a136f389a827e467ee21bb1dd148f46f844893bd560860bbd51926c8fc2")
        add_versions("3.13.1", "00c91291f6e6ba1bf09d8f2c83db8317cfe1e4043a76290fb306b4d7ed092760")
    end

    on_install("@windows", "@msys", "@cygwin", function (package)
        os.cp("*", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("py -0p")
    end)
