package("meson")
    set_kind("binary")
    set_homepage("https://mesonbuild.com/")
    set_description("Fast and user friendly build system.")
    set_license("Apache-2.0")

    add_urls("https://github.com/mesonbuild/meson/releases/download/$(version)/meson-$(version).tar.gz",
             "https://github.com/mesonbuild/meson.git")
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

    on_install("@macosx", "@linux", "@windows", "@msys", function (package)
        local envs = {PYTHONPATH = package:installdir()}
        local python = package:is_plat("windows") and "python" or "python3"
        os.vrunv(python, {"-m", "pip", "install", "--target=" .. package:installdir(), "."}, {envs = envs})
        package:addenv("PYTHONPATH", envs.PYTHONPATH)
    end)

    on_test(function (package)
        os.vrun("meson --version")
    end)
