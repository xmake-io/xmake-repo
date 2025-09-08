package("gyp-next")

    set_kind("binary")
    set_homepage("https://github.com/nodejs/gyp-next")
    set_description("A fork of the GYP build system for use in the Node.js projects")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/nodejs/gyp-next/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nodejs/gyp-next.git")
    add_versions("v0.20.4", "c010591b853eb79d625a3f10277dadbdc0b69a1c3aaadb3be81d0c91cf97bfba")
    add_versions("v0.20.2", "7684f8b8758152485d5dff030e6e1502adaeb65c6f4da5791ca0c5192c373f43")
    add_versions("v0.20.0", "b16de6130423c25f05e92329464feaf55dc51efc4557ddadfaf951770ca30252")
    add_versions("v0.19.1", "dc8fa22348d96055045eeadba938550b157ebcc275ddc7da8994eb0d54299e06")
    add_versions("v0.18.3", "9f48804a65941f53e453925ce1c628fe5a6a748f9d915ae02b5eb766c4f5a2d9")
    add_versions("v0.18.2", "d709119fa756fec7d7d2c7663553d73f6bf1ad4e139b4ec21fed5c65abc7bd3b")
    add_versions("v0.18.1", "f9be5e64a992688b651d64c6f269a8a701b843e089c048fae0733e9eb01dd48e")
    add_versions("v0.18.0", "2c0e002843da6a854d937a93d6fad5993954a457b3ffc2031d8af2dcff42caba")
    add_versions("v0.16.2", "145d5719a88112ae2631a88556361da3b8780f4179a928c823ba3d18ab796464")
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
