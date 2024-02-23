package("vsyasm")
    set_kind("binary")
    set_homepage("https://yasm.tortall.net/")
    set_description("Modular BSD reimplementation of NASM - for use with VS2010+")
    set_license("BSD-2-Clause")

    if os.arch() == "x64" then
        add_urls("https://github.com/yasm/yasm/releases/download/v$(version)/vsyasm-$(version)-win64.zip",
                    "http://www.tortall.net/projects/yasm/releases/vsyasm-$(version)-win64.zip")
        add_versions("1.3.0", "6d991ca77e3827aade0091c87c89cb4c9fa6ad097afcea95ea736482bae707e2")
    else
        add_urls("https://github.com/yasm/yasm/releases/download/v$(version)/vsyasm-$(version)-win32.zip",
                    "http://www.tortall.net/projects/yasm/releases/vsyasm-$(version)-win32.zip")
        add_versions("1.3.0", "ff4585e2a03e7015b0b1d406d4231267c2d3733968ffc6fc633e586c85c16da5")
    end

    on_install("@windows", "@mingw", "@msys", function (package)
        os.cp("*", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("vsyasm --version")
    end)
