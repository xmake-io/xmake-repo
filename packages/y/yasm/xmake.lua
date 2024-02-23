package("yasm")
    set_kind("binary")
    set_homepage("https://yasm.tortall.net/")
    set_description("Modular BSD reimplementation of NASM.")

    if is_host("windows") then
        if os.arch() == "x64" then
            add_urls("https://github.com/yasm/yasm/releases/download/$(version)/vsyasm-$(version)-win64.zip",
                     "http://www.tortall.net/projects/yasm/releases/vsyasm-$(version)-win64.zip")
            add_versions("1.3.0", "6D991CA77E3827AADE0091C87C89CB4C9FA6AD097AFCEA95EA736482BAE707E2")
        else
            add_urls("https://github.com/yasm/yasm/releases/download/$(version)/vsyasm-$(version)-win32.zip",
                     "http://www.tortall.net/projects/yasm/releases/vsyasm-$(version)-win32.zip")
            add_versions("1.3.0", "FF4585E2A03E7015B0B1D406D4231267C2D3733968FFC6FC633E586C85C16DA5")
        end
    else
        add_urls("https://www.tortall.net/projects/yasm/releases/yasm-$(version).tar.gz",
                 "https://ftp.openbsd.org/pub/OpenBSD/distfiles/yasm-$(version).tar.gz")
        add_versions("1.3.0", "3dce6601b495f5b3d45b59f7d2492a340ee7e84b5beca17e48f862502bd5603f")
    end

    on_install("@windows", "@mingw", "@msys", function (package)
        os.mv("vsyasm.exe", "yasm.exe")
        os.cp("*", package:installdir("bin"))
    end)
    
    on_install("@linux", "@macosx", function (package)
        local configs = {"--disable-python"}
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        os.vrun("yasm --version")
    end)
    