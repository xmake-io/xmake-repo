package("zig")

    set_kind("toolchain")
    set_homepage("https://www.ziglang.org/")
    set_description("Zig is a general-purpose programming language and toolchain for maintaining robust, optimal, and reusable software.")

    if is_host("macosx") then
        set_urls("https://ziglang.org/download/$(version)/zig-macos-x86_64-$(version).tar.xz")
        add_versions("0.7.1", "845cb17562978af0cf67e3993f4e33330525eaf01ead9386df9105111e3bc519")
        add_versions("0.9.1", "2d94984972d67292b55c1eb1c00de46580e9916575d083003546e9a01166754c")
        add_versions("0.10.0", "3a22cb6c4749884156a94ea9b60f3a28cf4e098a69f08c18fbca81c733ebfeda")
    elseif is_host("windows") then
        if os.arch() == "x86" then
            set_urls("https://ziglang.org/download/$(version)/zig-windows-i386-$(version).zip")
            add_versions("0.7.1", "a1b9a7421e13153e07fd2e2c93ff29aad64d83105b8fcdafa633dbe689caf1c0")
            add_versions("0.9.1", "74a640ed459914b96bcc572183a8db687bed0af08c30d2ea2f8eba03ae930f69")
        else
            set_urls("https://ziglang.org/download/$(version)/zig-windows-x86_64-$(version).zip")
            add_versions("0.7.1", "4818a8a65b4672bc52c0ae7f14d014e0eb8caf10f12c0745176820384cea296a")
            add_versions("0.9.1", "443da53387d6ae8ba6bac4b3b90e9fef4ecbe545e1c5fa3a89485c36f5c0e3a2")
            add_versions("0.10.0", "a66e2ff555c6e48781de1bcb0662ef28ee4b88af3af2a577f7b1950e430897ee")
        end
    elseif is_host("linux") then
        if os.arch() == "i386" then
            set_urls("https://ziglang.org/download/$(version)/zig-linux-i386-$(version).tar.xz")
            add_versions("0.7.1", "4882e052e5f83690bd0334bb4fc1702b5403cb3a3d2aa63fd7d6043d8afecba3")
            add_versions("0.9.1", "e776844fecd2e62fc40d94718891057a1dbca1816ff6013369e9a38c874374ca")
            add_versions("0.10.0", "dac8134f1328c50269f3e50b334298ec7916cb3b0ef76927703ddd1c96fd0115")
        elseif os.arch() == "arm64" then
            set_urls("https://ziglang.org/download/$(version)/zig-linux-aarch64-$(version).tar.xz")
            add_versions("0.7.1", "48ec90eba407e4587ddef7eecef25fec7e13587eb98e3b83c5f2f5fff2a5cbe7")
            add_versions("0.9.1", "5d99a39cded1870a3fa95d4de4ce68ac2610cca440336cfd252ffdddc2b90e66")
            add_versions("0.10.0", "09ef50c8be73380799804169197820ee78760723b0430fa823f56ed42b06ea0f")
        elseif os.arch() == "arm" or os.arch() == "armv7" then
            set_urls("https://ziglang.org/download/$(version)/zig-linux-armv7a-$(version).tar.xz")
            add_versions("0.7.1", "5a0662e07b4c4968665e1f97558f8591f6facec45d2e0ff5715e661743107ceb")
            add_versions("0.9.1", "6de64456cb4757a555816611ea697f86fba7681d8da3e1863fa726a417de49be")
            add_versions("0.10.0", "7201b2e89cd7cc2dde95d39485fd7d5641ba67dc6a9a58c036cb4c308d2e82de")
        else
            set_urls("https://ziglang.org/download/$(version)/zig-linux-x86_64-$(version).tar.xz")
            add_versions("0.7.1", "18c7b9b200600f8bcde1cd8d7f1f578cbc3676241ce36d771937ce19a8159b8d")
            add_versions("0.9.1", "be8da632c1d3273f766b69244d80669fe4f5e27798654681d77c992f17c237d7")
            add_versions("0.10.0", "631ec7bcb649cd6795abe40df044d2473b59b44e10be689c15632a0458ddea55")
        end
    elseif is_host("bsd") then
        set_urls("https://ziglang.org/download/$(version)/zig-freebsd-x86_64-$(version).tar.xz")
        add_versions("0.7.1", "e73c1dca35791a3183fdd5ecde0443ebbe180942efceafe651886034fb8def09")
        add_versions("0.9.1", "4e06009bd3ede34b72757eec1b5b291b30aa0d5046dadd16ecb6b34a02411254")
        add_versions("0.10.0", "dd77afa2a8676afbf39f7d6068eda81b0723afd728642adaac43cb2106253d65")
    end

    on_install("@macosx", "@linux", "@windows", "@msys", "@bsd", function (package)
        os.cp("*", package:installdir())
        package:addenv("PATH", ".")
    end)

    on_test(function (package)
        os.vrun("zig version")
    end)
