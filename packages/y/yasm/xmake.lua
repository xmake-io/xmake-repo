package("yasm")
    set_kind("binary")
    set_homepage("https://yasm.tortall.net/")
    set_description("Modular BSD reimplementation of NASM.")
    set_license("BSD-2-Clause")

    if is_host("windows") then
        if os.arch() == "x64" then
            add_urls("https://github.com/yasm/yasm/releases/download/v$(version)/yasm-$(version)-win64.exe",
                     "http://www.tortall.net/projects/yasm/releases/yasm-$(version)-win64.exe")
            add_versions("1.3.0", "d160b1d97266f3f28a71b4420a0ad2cd088a7977c2dd3b25af155652d8d8d91f")
        else
            add_urls("https://github.com/yasm/yasm/releases/download/v$(version)/yasm-$(version)-win32.exe",
                     "http://www.tortall.net/projects/yasm/releases/yasm-$(version)-win32.exe")
            add_versions("1.3.0", "db8ef9348ae858354cee4cc2f99e0f36de8a47a121de4cfeea5a16d45dd5ac1b")
        end
    else
        add_urls("https://www.tortall.net/projects/yasm/releases/yasm-$(version).tar.gz",
                 "https://ftp.openbsd.org/pub/OpenBSD/distfiles/yasm-$(version).tar.gz")
        add_versions("1.3.0", "3dce6601b495f5b3d45b59f7d2492a340ee7e84b5beca17e48f862502bd5603f")
    end

    on_install("@windows", "@mingw", "@msys", function (package)
        -- renaming the file and moving it to the right folder has to be in two steps to avoid xmake mistaking the filename for a folder
        os.vmv(package:originfile(), "yasm.exe")
        os.vmv("yasm.exe", package:installdir("bin"))
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
