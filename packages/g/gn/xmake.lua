package("gn")

    set_homepage("https://gn.googlesource.com/gn")
    set_description("GN is a meta-build system that generates build files for Ninja.")
    set_kind("binary")

    if is_host("windows") then
        if os.arch() == "x64" then
            add_urls("https://github.com/xmake-mirror/gn-releases/raw/v$(version)/gn-windows-amd64.zip")
            add_versions("20201128", "1cf7fbda62a585925391cc551053e0c6313a9c5aabc02c3c20c138c0ea6bc2bf")
        end
    elseif is_host("linux") then
        add_urls("https://github.com/xmake-mirror/gn-releases/raw/v$(version)/gn-linux-amd64.zip")
        add_versions("20201128", "756d6a88adcb157bd80eb4cea10df9e77fa1e7a328c67858b4c0cd0ab15c9f6e")
    elseif is_host("macosx") then
        if os.arch() == "arm64" then
            add_urls("https://github.com/xmake-mirror/gn-releases/raw/v$(version)/gn-mac-arm64.zip")
            add_versions("20201128", "be0be7cc48ced8124f1da53fe3c571cefa6390ccd7f531144e3dffd4b51e1138")
        else
            add_urls("https://github.com/xmake-mirror/gn-releases/raw/v$(version)/gn-mac-amd64.zip")
            add_versions("20201128", "34dc4171ec89cf7839c8ada4fec80860109b4af936688a3bfe9373c464667573")
        end
    end

    on_install("@windows", "@linux", "@macosx", function (package)
        os.cp("gn*", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("gn --version")
    end)
