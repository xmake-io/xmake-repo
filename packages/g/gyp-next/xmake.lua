package("gyp-next")

    set_kind("binary")
    set_homepage("https://github.com/nodejs/gyp-next")
    set_description("A fork of the GYP build system for use in the Node.js projects")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/nodejs/gyp-next/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nodejs/gyp-next.git")
    add_versions("v0.16.1", "892fecef9ca3fa1eff8bd18b7bcec54c6e8a2203788c048d26bccb53d9fcf737")
    add_versions("v0.11.0", "27fc51481d0e71d7fdc730b4c86dcee9825d11071875384d5fe4b263935501ef")

    add_deps("python 3.x", {kind = "binary"})
    on_install("@windows", "@macosx", "@linux", function (package)
        os.cp("*", package:installdir())
        package:addenv("PATH", ".")
    end)

    on_test(function (package)
        if is_host("windows") then
            os.vrun("gyp.bat --help")
        else
            os.vrun("gyp --help")
        end
    end)
