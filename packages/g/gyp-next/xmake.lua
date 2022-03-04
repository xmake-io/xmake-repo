package("gyp-next")

    set_kind("binary")
    set_homepage("https://github.com/nodejs/gyp-next")
    set_description("A fork of the GYP build system for use in the Node.js projects")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/nodejs/gyp-next/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nodejs/gyp-next.git")
    add_versions("v0.11.0", "27fc51481d0e71d7fdc730b4c86dcee9825d11071875384d5fe4b263935501ef")

    add_deps("python 3.x", {kind = "binary"})
    on_install("@windows", "@macosx", "@linux", function (package)
        os.cp("*", package:installdir())
        package:addenv("PATH", ".")
    end)

    on_test(function (package)
        if is_host("windows") then
            os.vrun("cmd /c \"gyp --help\"")
        else
            os.vrun("gyp --help")
        end
    end)
