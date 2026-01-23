package("xtensa-esp-elf")
    set_kind("toolchain")
    set_homepage("https://github.com/espressif/crosstool-NG")
    set_description("crosstool-NG with support for Xtensa")
    set_license("GPL-3.0-with-GCC-exception")

    if is_host("windows") then
        if os.arch() == "x86_64" then
            set_urls("https://github.com/espressif/crosstool-NG/releases/download/esp-$(version)/xtensa-esp-elf-$(version)-x86_64-w64-mingw32.zip")

            add_versions("15.2.0_20251204", "efa1e337b5f64239674bf755b767969cbba7f4e66fe7c6ab8d19b650f56012a9")
            add_versions("14.2.0_20251208", "9295d0d2f847c1424d81c88f0b4064bbc72224bf7b93a50d12893a99e13b154f")
        elseif os.arch() == "x86" then
            set_urls("https://github.com/espressif/crosstool-NG/releases/download/esp-$(version)/xtensa-esp-elf-$(version)-i686-w64-mingw32.zip")

            add_versions("15.2.0_20251204", "72403f48827f75495f7c0b1c2be9f643c8dac25af7722545fc3ba1f21e834389")
            add_versions("14.2.0_20251208", "7f11fe40a44968501802d92da54c4cd3d04208fd06ac40fcbcdcebf78f05b94d")
        end
    elseif is_host("linux") then
        if os.arch() == "x86_64" then
            set_urls("https://github.com/espressif/crosstool-NG/releases/download/esp-$(version)/xtensa-esp-elf-$(version)-x86_64-linux-gnu.tar.xz")

            add_versions("15.2.0_20251204", "3d50f5cd5f173acfd524e07c1cd69bc99585731a415ca2e5bce879997fe602b8")
            add_versions("14.2.0_20251208", "0c276362cd31d095d1d80fc1eb38929b8d779e604d392b3a2fb4958f0ee718fe")
        elseif os.arch() == "x86" then
            set_urls("https://github.com/espressif/crosstool-NG/releases/download/esp-$(version)/xtensa-esp-elf-$(version)-i586-linux-gnu.tar.xz")

            add_versions("15.2.0_20251204", "6d3c510ddf5f084734c1dd5671d87a7b13973d713f641596ec1351dcce8d3ff3")
            add_versions("14.2.0_20251208", "9e8e1cf22db4a5767a01e2cbcc1551cab5ecb66aea7ba33a2c552783829d5694")
        elseif os.arch() == "arm64" then
            set_urls("https://github.com/espressif/crosstool-NG/releases/download/esp-$(version)/xtensa-esp-elf-$(version)-aarch64-linux-gnu.tar.xz")

            add_versions("15.2.0_20251204", "c8a8255009803036ba3def98a97a7134ee5a8ac5db048425e126fcf07f27ce1c")
            add_versions("14.2.0_20251208", "6d0429c047cb5c78bc1cc5d574d6de4bbf7ef37129c200e075b8c52b6ef821b0")
        elseif os.arch() == "armel" then
            set_urls("https://github.com/espressif/crosstool-NG/releases/download/esp-$(version)/xtensa-esp-elf-$(version)-arm-linux-gnueabi.tar.xz")

            add_versions("15.2.0_20251204", "0ae215a8adb2823b370e31d20891747af42b86ce5042331df50829942d8cbbfe")
            add_versions("14.2.0_20251208", "932a06411839f49fc59563adccc0eb61c46caa17e101e20bfe429993cf901ad4")
        elseif os.arch() == "armhf" then
            set_urls("https://github.com/espressif/crosstool-NG/releases/download/esp-$(version)/xtensa-esp-elf-$(version)-arm-linux-gnueabihf.tar.xz")

            add_versions("15.2.0_20251204", "99c1b5d45e9d661457d7a98494e5ebb2ed2e01b4b4dd4861de750acaec15a7bc")
            add_versions("14.2.0_20251208", "e3e8ff454c3bf39f1546a8ff5b423507c4512735e547aa30b44622709db181f1")
        end
        
    elseif is_host("macosx") then
        if os.arch() == "x86_64" then
            set_urls("https://github.com/espressif/crosstool-NG/releases/download/esp-$(version)/xtensa-esp-elf-$(version)-x86_64-apple-darwin.tar.xz")

            add_versions("15.2.0_20251204", "96da1fcf01e2ac89819d1e336ca9e27762c35ea120627b89de8fd482f42c54f8")
            add_versions("14.2.0_20251208", "f5259d9e6235e6fb573524d7139bbec4e316211d52953960c809687412e8250b")
        elseif os.arch() == "arm64" then
            set_urls("https://github.com/espressif/crosstool-NG/releases/download/esp-$(version)/xtensa-esp-elf-$(version)-aarch64-apple-darwin.tar.xz")

            add_versions("15.2.0_20251204", "68d3fb1e75c6bb1b88c6a2c74977abd51efd09b560a99149bafdcf403cb21941")
            add_versions("14.2.0_20251208", "73f31f1232113ca12fef9e1125b9318a339d1e2b0d29a4b6bcd89cf571b857f8")
        end
    end

    on_install("@windows", "@linux", "@macosx", function(package)
        os.cp("*", package:installdir())
    end)

    on_test(function (package)
        local gcc = "xtensa-esp-elf-gcc"
        if gcc and is_host("windows") then
            gcc = gcc .. ".exe"
        end
        os.vrunv(gcc, {"--version"})
    end)
