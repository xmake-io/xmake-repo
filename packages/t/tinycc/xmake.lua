package("tinycc")

    set_kind("toolchain")
    set_homepage("https://bellard.org/tcc/")
    set_description("Tiny C Compiler")

    if is_host("windows") then
        if os.arch() == "x86" then
            set_urls("http://download.savannah.gnu.org/releases/tinycc/tcc-$(version)-win32-bin.zip")
            add_versions("0.9.27", "02e2bfe8c272a549b15e4bfa4507bd7e05304692af1761db6c1e8e88af675651")
        else
            set_urls("http://download.savannah.gnu.org/releases/tinycc/tcc-$(version)-win64-bin.zip")
            add_versions("0.9.27", "34a721949a2583fdff725312da092fa0f5f1f284b702e6f811c6954714faabb2")
        end
    else
        set_urls("http://download.savannah.gnu.org/releases/tinycc/tcc-$(version).tar.bz2")
        add_versions("0.9.27", "de23af78fca90ce32dff2dd45b3432b2334740bb9bb7b05bf60fdbfc396ceb9c")
    end

    on_fetch(function (package, opt)
        if opt.system then
            return import("lib.detect.find_tool")("tcc")
        end
    end)

    on_install("windows", function (package)
        os.vcp("include", package:installdir())
        os.vcp("lib", package:installdir())
        os.vcp("*.exe", package:installdir("bin"))
        os.vcp("*.dll", package:installdir("bin"))
        os.vcp("libtcc", package:installdir("bin"))
    end)

    on_install("macosx", "linux", "bsd", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        os.vrun("tcc -v")
    end)
