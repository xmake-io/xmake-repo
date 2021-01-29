package("zig")

    set_kind("binary")
    set_homepage("https://www.ziglang.org/")
    set_description("Zig is a general-purpose programming language and toolchain for maintaining robust, optimal, and reusable software.")

    if is_host("macosx") then
        set_urls("https://ziglang.org/download/$(version)/zig-macos-x86_64-$(version).tar.xz")
        add_versions("0.7.1", "845cb17562978af0cf67e3993f4e33330525eaf01ead9386df9105111e3bc519")
    elseif is_host("windows") then
        if is_arch("x86") then
            set_urls("https://ziglang.org/download/$(version)/zig-windows-i386-$(version).zip")
            add_versions("0.7.1", "a1b9a7421e13153e07fd2e2c93ff29aad64d83105b8fcdafa633dbe689caf1c0")
        else
            set_urls("https://ziglang.org/download/$(version)/zig-windows-x86_64-$(version).zip")
            add_versions("0.7.1", "4818a8a65b4672bc52c0ae7f14d014e0eb8caf10f12c0745176820384cea296a")
        end
    elseif is_host("linux") then
        if is_arch("i386") then
            set_urls("https://ziglang.org/download/$(version)/zig-linux-i386-$(version).tar.xz")
            add_versions("0.7.1", "4882e052e5f83690bd0334bb4fc1702b5403cb3a3d2aa63fd7d6043d8afecba3")
        elseif is_arch("arm64") then
            set_urls("https://ziglang.org/download/$(version)/zig-linux-aarch64-$(version).tar.xz")
            add_versions("0.7.1", "48ec90eba407e4587ddef7eecef25fec7e13587eb98e3b83c5f2f5fff2a5cbe7")
        elseif is_arch("arm", "armv7") then
            set_urls("https://ziglang.org/download/$(version)/zig-linux-armv7a-$(version).tar.xz")
            add_versions("0.7.1", "5a0662e07b4c4968665e1f97558f8591f6facec45d2e0ff5715e661743107ceb")
        else
            set_urls("https://ziglang.org/download/$(version)/zig-linux-x86_64-$(version).tar.xz")
            add_versions("0.7.1", "18c7b9b200600f8bcde1cd8d7f1f578cbc3676241ce36d771937ce19a8159b8d")
        end
    elseif is_host("bsd") then
        set_urls("https://ziglang.org/download/$(version)/zig-freebsd-x86_64-$(version).tar.xz")
        add_versions("0.7.1", "e73c1dca35791a3183fdd5ecde0443ebbe180942efceafe651886034fb8def09")
    end

    on_install("macosx", "linux", "windows", "bsd", function (package)
        os.cp("*", package:installdir())
        package:addenv("PATH", package:installdir())
    end)

    on_test(function (package)
        os.vrun("zig version")
    end)
