package("nasm")

    set_kind("binary")
    set_homepage("https://www.nasm.us/")
    set_description("Netwide Assembler (NASM) is an 80x86 assembler.")
    set_license("BSD-2-Clause")

    if is_host("windows") then
        if os.arch() == "x64" then
            add_urls("https://www.nasm.us/pub/nasm/releasebuilds/$(version)/win64/nasm-$(version)-win64.zip")
            add_urls("https://github.com/xmake-mirror/nasm/releases/download/nasm-$(version)/nasm-$(version)-win64.zip")
            add_versions("2.15.05", "f5c93c146f52b4f1664fa3ce6579f961a910e869ab0dae431bd871bdd2584ef2")
            add_versions("2.16.01", "029eed31faf0d2c5f95783294432cbea6c15bf633430f254bb3c1f195c67ca3a")
            add_versions("2.16.03", "3ee4782247bcb874378d02f7eab4e294a84d3d15f3f6ee2de2f47a46aa7226e6")
        else
            add_urls("https://www.nasm.us/pub/nasm/releasebuilds/$(version)/win32/nasm-$(version)-win32.zip")
            add_urls("https://github.com/xmake-mirror/nasm/releases/download/nasm-$(version)/nasm-$(version)-win32.zip")
            add_versions("2.15.05", "258c7d1076e435511cf2fdf94e2281eadbdb9e3003fd57f356f446e2bce3119e")
            add_versions("2.16.01", "e289fa70c88594b092c916344bb8bfcd6896b604bfab284ab57b1372997c820c")
            add_versions("2.16.03", "1881d062da8a2f02d832c3d47262697817541bcbb853126638ad209ea6ffe5b0")
        end
    else
        add_urls("https://www.nasm.us/pub/nasm/releasebuilds/$(version)/nasm-$(version).tar.xz")
        add_urls("https://github.com/xmake-mirror/nasm/releases/download/nasm-$(version)/nasm-$(version).tar.xz")
        add_versions("2.13.03", "812ecfb0dcbc5bd409aaa8f61c7de94c5b8752a7b00c632883d15b2ed6452573")
        add_versions("2.15.05", "3caf6729c1073bf96629b57cee31eeb54f4f8129b01902c73428836550b30a3f")
        add_versions("2.16.01", "c77745f4802375efeee2ec5c0ad6b7f037ea9c87c92b149a9637ff099f162558")
        add_versions("2.16.03", "1412a1c760bbd05db026b6c0d1657affd6631cd0a63cddb6f73cc6d4aa616148")
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
