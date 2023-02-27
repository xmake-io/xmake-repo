package("ninja")

    set_kind("binary")
    set_homepage("https://ninja-build.org/")
    set_description("Small build system for use with gyp or CMake.")

    if is_host("windows") then
        set_urls("https://github.com/ninja-build/ninja/releases/download/v$(version)/ninja-win.zip")
        add_versions("1.9.0", "2d70010633ddaacc3af4ffbd21e22fae90d158674a09e132e06424ba3ab036e9")
        add_versions("1.10.1", "5d1211ea003ec9760ad7f5d313ebf0b659d4ffafa221187d2b4444bc03714a33")
        add_versions("1.10.2", "bbde850d247d2737c5764c927d1071cbb1f1957dcabda4a130fa8547c12c695f")
        add_versions("1.11.0", "d0ee3da143211aa447e750085876c9b9d7bcdd637ab5b2c5b41349c617f22f3b")
        add_versions("1.11.1", "524b344a1a9a55005eaf868d991e090ab8ce07fa109f1820d40e74642e289abc")
    elseif is_host("macosx") then
        set_urls("https://github.com/ninja-build/ninja/releases/download/v$(version)/ninja-mac.zip")
        add_versions("1.9.0", "26d32a79f786cca1004750f59e545199bf110e21e300d3c2424c1fddd78f28ab")
        add_versions("1.10.1", "0bd650190d4405c15894055e349d9b59d5690b0389551d757c5ed2d3841972d1")
        add_versions("1.10.2", "6fa359f491fac7e5185273c6421a000eea6a2f0febf0ac03ac900bd4d80ed2a5")
        add_versions("1.11.0", "21915277db59756bfc61f6f281c1f5e3897760b63776fd3d360f77dd7364137f")
        add_versions("1.11.1", "482ecb23c59ae3d4f158029112de172dd96bb0e97549c4b1ca32d8fad11f873e")
    elseif is_host("linux", "bsd") then
        add_urls("https://github.com/ninja-build/ninja/archive/refs/tags/v$(version).tar.gz",
                 "https://github.com/ninja-build/ninja.git")
        add_versions("1.9.0", "5d7ec75828f8d3fd1a0c2f31b5b0cea780cdfe1031359228c428c1a48bfcd5b9")
        add_versions("1.10.1", "a6b6f7ac360d4aabd54e299cc1d8fa7b234cd81b9401693da21221c62569a23e")
        add_versions("1.10.2", "ce35865411f0490368a8fc383f29071de6690cbadc27704734978221f25e2bed")
        add_versions("1.11.0", "3c6ba2e66400fe3f1ae83deb4b235faf3137ec20bd5b08c29bfc368db143e4c6")
        add_versions("1.11.1", "31747ae633213f1eda3842686f83c2aa1412e0f5691d1c14dbbcc67fe7400cea")
    end

    on_load("linux", "bsd", function (package)
        package:add("deps", package:version():ge("1.10.0") and "python" or "python2", {kind = "binary"})
    end)

    on_install("@windows", "@msys", "@cygwin", function (package)
        os.cp("./ninja.exe", package:installdir("bin"))
    end)

    on_install("@macosx", function (package)
        os.cp("./ninja", package:installdir("bin"))
    end)

    on_install("@linux", "@bsd", function (package)
        import("lib.detect.find_tool")
        local python = assert(find_tool("python"), "python not found!")
        os.vrunv(python.program, {"configure.py", "--bootstrap"})
        os.cp("./ninja", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("ninja --version")
    end)
