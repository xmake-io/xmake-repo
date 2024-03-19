package("nim")
    set_kind("toolchain")
    set_homepage("https://nim-lang.org/")
    set_description("Nim is a statically typed compiled systems programming language")

    local precompiled = false
    if is_host("windows") then
        if os.arch() == "x86" then
            add_urls("https://nim-lang.org/download/nim-$(version)_x32.zip")
            add_versions("2.0.2", "d076d35fdab29baf83c66f1135a1fd607eb61d4c14037706f7be3ba58fb83d87")
            precompiled = true
        elseif os.arch() == "x64" then
            add_urls("https://nim-lang.org/download/nim-$(version)_x64.zip")
            add_versions("2.0.2", "948dbf8e3fdd1b5242e3d662fd25c50e9b2586e097be8a85c22d7db2bde70bad")
            precompiled = true
        end
    end
    if not precompiled then
        add_urls("https://github.com/nim-lang/Nim/archive/refs/tags/v$(version).tar.gz")
        add_versions("2.0.2", "2ca2f559d05e29f130cb4f319ebb93a98e7c0e2187716b17b2cb4e747f5ff798")
    end

    on_install("@windows", "@msys", function (package)
        os.cp("*", package:installdir())
    end)

    on_install("@windows|arm64", function (package)
        os.vrunv("./build_all.bat", {}, {shell = true})
        os.cp("bin", package:installdir())
    end)

    on_install("@macosx", "@linux", function (package)
        os.vrunv("./build_all.sh", {}, {shell = true})
        os.cp("bin", package:installdir())
    end)

    on_test(function (package)
        os.vrun("nim --version")
        os.vrun("nimble --version")
    end)
