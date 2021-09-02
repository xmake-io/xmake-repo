package("meson")

    set_kind("binary")
    set_homepage("https://mesonbuild.com/")
    set_description("Fast and user friendly build system.")
    set_license("Apache-2.0")

    add_urls("https://github.com/mesonbuild/meson/releases/download/$(version)/meson-$(version).tar.gz",
             "https://github.com/mesonbuild/meson.git")
    add_versions("0.59.1", "db586a451650d46bbe10984a87b79d9bcdc1caebf38d8e189f8848f8d502356d")
    add_versions("0.58.1", "3144a3da662fcf79f1e5602fa929f2821cba4eba28c2c923fe0a7d3e3db04d5d")
    add_versions("0.58.0", "f4820df0bc969c99019fd4af8ca5f136ee94c63d8a5ad67e7eb73bdbc9182fdd")
    add_versions("0.56.0", "291dd38ff1cd55fcfca8fc985181dd39be0d3e5826e5f0013bf867be40117213")
    add_versions("0.50.1", "f68f56d60c80a77df8fc08fa1016bc5831605d4717b622c96212573271e14ecc")

    add_deps("ninja", "python 3.x", {kind = "binary"})

    on_install("@macosx", "@linux", "@windows", function (package)
        local envs = {PYTHONPATH = package:installdir()}
        local python = package:is_plat("windows") and "python" or "python3"
        os.vrunv(python, {"-m", "pip", "install", "--target=" .. package:installdir(), "."}, {envs = envs})
        package:addenv("PYTHONPATH", envs.PYTHONPATH)
    end)

    on_test(function (package)
        os.vrun("meson --version")
    end)
