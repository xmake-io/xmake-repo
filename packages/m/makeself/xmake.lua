package("makeself")
    set_kind("binary")
    set_homepage("https://makeself.io")
    set_description("A self-extracting archiving tool for Unix systems, in 100% shell script.")

    add_urls("https://github.com/megastep/makeself/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return "release-" .. version
    end})

    add_versions("2.5.0", "705d0376db9109a8ef1d4f3876c9997ee6bed454a23619e1dbc03d25033e46ea")

    on_install("macosx", "linux", "msys", "bsd", function (package)
        os.cp("*.sh", package:installdir("bin"))
    end)

    on_test(function (package)
        os.runv("makeself.sh", {"--version"}, {shell = true})
    end)
