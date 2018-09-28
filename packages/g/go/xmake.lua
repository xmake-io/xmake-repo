package("go")

    set_kind("binary")
    set_homepage("https://golang.org/")
    set_description("The Go Programming Language")

    if is_host("windows") then
        if is_arch("x64") then
            set_urls("https://dl.google.com/go/go$(version).windows-amd64.zip")
            add_versions("1.11", "29f9291270f0b303d0b270f993972ead215b1bad3cc674a0b8a09699d978aeb4")
        else
            set_urls("https://dl.google.com/go/go$(version).windows-386.zip")
            add_versions("1.11", "d3279f0e3d728637352eff0aa1e11268a0eb01f13644bcbce1c066139f5a90db")
        end
    elseif is_host("linux") then
        if is_arch("x86_64") then
            set_urls("https://dl.google.com/go/go$(version).linux-amd64.tar.gz")
            add_versions("1.11", "b3fcf280ff86558e0559e185b601c9eade0fd24c900b4c63cd14d1d38613e499")
        elseif is_arch("i386") then
            set_urls("https://dl.google.com/go/go$(version).linux-386.tar.gz")
            add_versions("1.11", "1a91932b65b4af2f84ef2dce10d790e6a0d3d22c9ea1bdf3d8c4d9279dfa680e")
        elseif is_arch("arm*") then
            set_urls("https://dl.google.com/go/go$(version).linux-armv6l.tar.gz")
            add_versions("1.11", "8ffeb3577d8ca5477064f1cb8739835973c866487f2bf81df1227eaa96826acd")
        end
    elseif is_host("macosx") then
        if is_arch("x86_64") then
            set_urls("https://dl.google.com/go/go$(version).darwin-amd64.tar.gz")
            add_versions("1.11", "9749e6cb9c6d05cf10445a7c9899b58e72325c54fee9783ed1ac679be8e1e073")
        end
    end

    on_install("macosx", "linux", "windows", function (package)
        os.cp("bin", package:installdir())
        os.cp("lib", package:installdir())
        os.cp("pkg", package:installdir())
        os.cp("misc", package:installdir())
    end)

    on_test(function (package)
        os.vrun("go help")
    end)
