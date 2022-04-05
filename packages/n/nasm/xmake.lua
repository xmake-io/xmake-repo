package("nasm")

    set_kind("binary")
    set_homepage("https://www.nasm.us/")
    set_description("Netwide Assembler (NASM) is an 80x86 assembler.")
    set_license("BSD-2-Clause")

    if is_host("windows") then
        if os.arch() == "x64" then
            add_urls("https://github.com/xmake-mirror/nasm/releases/download/nasm-$(version)/nasm-$(version)-win64.zip")
            add_versions("2.15.05", "f5c93c146f52b4f1664fa3ce6579f961a910e869ab0dae431bd871bdd2584ef2")
        else
            add_urls("https://github.com/xmake-mirror/nasm/releases/download/nasm-$(version)/nasm-$(version)-win32.zip")
            add_versions("2.15.05", "258c7d1076e435511cf2fdf94e2281eadbdb9e3003fd57f356f446e2bce3119e")
        end
    else
        add_urls("https://github.com/xmake-mirror/nasm/releases/download/nasm-$(version)/nasm-$(version).tar.xz")
        add_versions("2.13.03", "812ecfb0dcbc5bd409aaa8f61c7de94c5b8752a7b00c632883d15b2ed6452573")
        add_versions("2.15.05", "3caf6729c1073bf96629b57cee31eeb54f4f8129b01902c73428836550b30a3f")
    end

    on_install("@windows", "@mingw", "@msys", function (package)
        os.cp("*.exe", package:installdir("bin"))
        os.cp(path.join("rdoff", "*.exe"), package:installdir("bin"))
    end)

    on_install("@linux", "@macosx", "@bsd", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        os.vrun("nasm --version")
    end)
