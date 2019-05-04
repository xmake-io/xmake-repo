package("ninja")

    set_kind("binary")
    set_homepage("https://ninja-build.org/")
    set_description("Small build system for use with gyp or CMake.")

    add_urls("https://github.com/ninja-build/ninja/archive/v$(version).tar.gz",
             "https://github.com/ninja-build/ninja.git")
    add_versions("1.9.0", "5d7ec75828f8d3fd1a0c2f31b5b0cea780cdfe1031359228c428c1a48bfcd5b9")

    if not is_host("macosx") then
        add_deps("python 2.x")
    end

    on_install("linux", "macosx", "windows", function (package)
        os.vrun("python configure.py --bootstrap")
        os.vrun("./configure.py")
        os.cp("./ninja", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("ninja --version")
    end)
