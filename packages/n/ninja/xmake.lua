package("ninja")

    set_kind("binary")
    set_homepage("https://ninja-build.org/")
    set_description("Small build system for use with gyp or CMake.")

    if is_host("windows") then
        set_urls("https://github.com/ninja-build/ninja/releases/download/v$(version)/ninja-win.zip")
        add_versions("1.9.0", "2d70010633ddaacc3af4ffbd21e22fae90d158674a09e132e06424ba3ab036e9")
    elseif is_host("macosx") then
        set_urls("https://github.com/ninja-build/ninja/releases/download/v$(version)/ninja-mac.zip")
        add_versions("1.9.0", "26d32a79f786cca1004750f59e545199bf110e21e300d3c2424c1fddd78f28ab")
    elseif is_host("linux") then
        set_urls("https://github.com/ninja-build/ninja/releases/download/v$(version)/ninja-linux.zip")
        add_versions("1.9.0", "1b1235f2b0b4df55ac6d80bbe681ea3639c9d2c505c7ff2159a3daf63d196305")
    end

    on_install("windows", function (package)
        os.cp("./ninja.exe", package:installdir("bin"))
    end)

    on_install("linux", "macosx", function (package)
        os.cp("./ninja", package:installdir("bin"))
    end)
 
    on_test(function (package)
        os.vrun("ninja --version")
    end)
