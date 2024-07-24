package("jom")
    set_kind("binary")
    set_homepage("https://www.qt.io/")
    set_description("the parallel make tool for Windows.")
    set_license("GPL")

    add_urls("https://download.qt.io/official_releases/jom/jom_$(version).zip", {version = function (version)
        return version:gsub("%.", "_")
    end})

    add_versions("1.1.4", "d533c1ef49214229681e90196ed2094691e8c4a0a0bef0b2c901debcb562682b")
    add_versions("1.1.3", "128fdd846fe24f8594eed37d1d8929a0ea78df563537c0c1b1861a635013fff8")

    on_install("@windows", function (package)
        os.cp("*", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("jom /VERSION")
    end)
