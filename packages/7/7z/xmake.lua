package("7z")

    set_kind("binary")
    set_homepage("https://www.7-zip.org/")
    set_description("A file archiver with a high compression ratio.")

    if is_host("windows") then
        if is_arch("x64", "x86_64") then
            set_urls("https://github.com/xmake-mirror/7zip/releases/download/$(version)/7z$(version)-x64.zip",
                     "https://gitlab.com/xmake-mirror/7zip-releases/raw/master/7z$(version)-x64.zip")
            add_versions("19.00", "fc21cf510d70a69bfa8e5b0449fe0a054fb76e2f8bd568364821f319c8b1d86d")
            add_versions("18.05", "e6e2d21e2c482f1b1c5a6d21ed80800ce1273b902cf4b9afa68621545540ee2f")
        else
            set_urls("https://github.com/xmake-mirror/7zip/releases/download/$(version)/7z$(version)-x86.zip",
                     "https://gitlab.com/xmake-mirror/7zip-releases/raw/master/7z$(version)-x86.zip")
            add_versions("19.00", "f84fab081a2d8a6b5868a2eaf01cd56017363fb24560259cea80567f8062334f")
            add_versions("18.05", "544c37bebee30437aba405071484e0ac6310332b4bdabe4ca7420a800d4b4b5e")
        end
    else
        add_urls("https://github.com/jinfeihan57/p7zip/archive/refs/tags/v$(version).tar.gz")
        add_urls("https://github.com/jinfeihan57/p7zip.git")
        add_versions("17.04", "ea029a2e21d2d6ad0a156f6679bd66836204aa78148a4c5e498fe682e77127ef")
    end

    on_install("macosx", "linux", function (package)
        os.vrun("make 7z")
        os.cp("bin", package:installdir())
    end)

    on_install("windows", function (package)
        os.cp("*", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("7z --help")
    end)
