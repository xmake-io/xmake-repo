package("meson")
    set_kind("binary")
    set_homepage("https://mesonbuild.com/")
    set_description("Fast and user friendly build system.")
    set_license("Apache-2.0")

    add_urls("https://github.com/mesonbuild/meson/releases/download/$(version)/meson-$(version).tar.gz",
             "https://github.com/mesonbuild/meson.git")
    add_versions("1.6.0", "999b65f21c03541cf11365489c1fad22e2418bb0c3d50ca61139f2eec09d5496")
    add_versions("1.5.2", "f955e09ab0d71ef180ae85df65991d58ed8430323de7d77a37e11c9ea630910b")
    add_versions("1.5.1", "567e533adf255de73a2de35049b99923caf872a455af9ce03e01077e0d384bed")
    add_versions("1.4.2", "ea2546a26f4a171a741c1fd036f22c9c804d6198e3259f1df588e01f842dd69f")
    add_versions("1.4.1", "1b8aad738a5f6ae64294cc8eaba9a82988c1c420204484ac02ef782e5bba5f49")
    add_versions("1.4.0", "8fd6630c25c27f1489a8a0392b311a60481a3c161aa699b330e25935b750138d")
    add_versions("1.3.2", "492eb450c8b073024276f916f5adbb3c4bb7e90e9e6ec124efda064f3d9b5baa")
    add_versions("1.3.1", "6020568bdede1643d4fb41e28215be38eff5d52da28ac7d125457c59e0032ad7")
    add_versions("1.3.0", "4ba253ef60e454e23234696119cbafa082a0aead0bd3bbf6991295054795f5dc")
    add_versions("1.1.1",  "d04b541f97ca439fb82fab7d0d480988be4bd4e62563a5ca35fadb5400727b1c")
    add_versions("1.1.0",  "d9616c44cd6c53689ff8f05fc6958a693f2e17c3472a8daf83cee55dabff829f")
    add_versions("1.0.0",  "aa50a4ba4557c25e7d48446abfde857957dcdf58385fffbe670ba0e8efacce05")
    add_versions("0.62.1", "a0f5caa1e70da12d5e63aa6a9504273759b891af36c8d87de381a4ed1380e845")
    add_versions("0.61.2", "0233a7f8d959079318f6052b0939c27f68a5de86ba601f25c9ee6869fb5f5889")
    add_versions("0.60.1", "5add789c953d984b500858b2851ee3d7add0460cf1a6f852f0a721af17384e13")
    add_versions("0.59.2", "13dee549a7ba758b7e33ce7719f28d1d337a98d10d378a4779ccc996f5a2fc49")
    add_versions("0.59.1", "db586a451650d46bbe10984a87b79d9bcdc1caebf38d8e189f8848f8d502356d")
    add_versions("0.58.1", "3144a3da662fcf79f1e5602fa929f2821cba4eba28c2c923fe0a7d3e3db04d5d")
    add_versions("0.58.0", "f4820df0bc969c99019fd4af8ca5f136ee94c63d8a5ad67e7eb73bdbc9182fdd")
    add_versions("0.56.0", "291dd38ff1cd55fcfca8fc985181dd39be0d3e5826e5f0013bf867be40117213")
    add_versions("0.50.1", "f68f56d60c80a77df8fc08fa1016bc5831605d4717b622c96212573271e14ecc")

    add_deps("python 3.x", {kind = "binary"})

    -- https://github.com/xmake-io/xmake-repo/issues/1937
    set_policy("package.precompiled", false)

    on_install("@macosx", "@linux", "@bsd", "@windows", "@msys", function (package)
        local envs = {PYTHONPATH = package:installdir()}
        local python = package:is_plat("windows") and "python" or "python3"
        os.vrunv(python, {"-m", "pip", "install", "--target=" .. package:installdir(), "."}, {envs = envs})
        package:addenv("PYTHONPATH", envs.PYTHONPATH)
    end)

    on_test(function (package)
        os.vrun("meson --version")
    end)
