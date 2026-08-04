package("esptool")
    set_kind("binary")
    set_homepage("https://github.com/espressif/esptool")
    set_description("Espressif SoC serial bootloader utility, used to flash and image ESP chips")
    set_license("GPL-2.0-or-later")

    local variants = {
        windows = {
            x86_64 = {suffix = "windows-amd64.zip", versions = {
                ["5.3.1"] = "2b4a73c45db27426685896f64ce3e557f63a64f43cc100cb65c0cc3486af96d3",
                ["5.2.0"] = "ef0522120afb5e8e673d68726c32e0de416990fc62dc313191721edeb0a74fc6",
                ["5.1.0"] = "f68a8f7728adfc59cd60f9424928199e76eac66372c7bdc23898aa32753a437a"
            }}
        },
        linux = {
            x86_64 = {suffix = "linux-amd64.tar.gz", versions = {
                ["5.3.1"] = "e9cc641f8e4a0b644b52836d7a6b59f3c6d3261213c5ccc41f8f3c3035d06aa4",
                ["5.2.0"] = "0a9f6c913fccfacac9261eb2acd8060010db5933c18c8e47cb32377eaa7202a3",
                ["5.1.0"] = "49d572d50f6b1f089d1d81d3bd3bd357fbcc40f4f8fd4874f2dc51ad534abb01"
            }},
            arm64 = {suffix = "linux-aarch64.tar.gz", versions = {
                ["5.3.1"] = "dd2613cdc8e73d1200a3daff2025ff51daa5bbdb3a352fe35d6b7377891aecc8",
                ["5.2.0"] = "a3a0fc13ada8d69dddbdfff1c765fa0b88fb578a83d02315be9c15fefa6ca58e",
                ["5.1.0"] = "d2b60d4570cd4919b87eddcbeaab2e0411548b5aab865c234aed8ecc8e5403ac"
            }},
            armhf = {suffix = "linux-armv7.tar.gz", versions = {
                ["5.3.1"] = "54a2f902acf47dd4542c1ed6958eb9442fe818a16a7ecfaeaab57b872e7e8460",
                ["5.2.0"] = "dbf92966eb6ad5f4d068d8b2461f534b15219cb405083a38d26519284e91b73a",
                ["5.1.0"] = "e22ecb0293fe73c80d0a5fd05873f9ea49a68985b16991cf5980d2b90c8c7276"
            }}
        },
        macosx = {
            x86_64 = {suffix = "macos-amd64.tar.gz", versions = {
                ["5.3.1"] = "f8ec4fcaf7d79845a0e8ad60b24be9f584d8fe03f341b5ad4ec0df0ec855e670",
                ["5.2.0"] = "dcb6c38cb10e1d7ca5ce658687e4abe47dfda22284857673b55cae010ff5f5ee",
                ["5.1.0"] = "c485511e0906cb1e0277c5eecff1c4a77b89d76d0c940b685dc9fce2fad4b242"
            }},
            arm64 = {suffix = "macos-arm64.tar.gz", versions = {
                ["5.3.1"] = "f63f7203d88cfe4c17aea34d6cf82769458ce204e49a05816c6384c2d299e6ca",
                ["5.2.0"] = "2b45270273ff96b6394bd6e317b153cf4a42869ca917d2bcebafc9a3cdac0e1e",
                ["5.1.0"] = "5d5aab5b64b10dc5001cfa96b5bfa48393ae561e6d797c41a1fdd3f5d3843d03"
            }}
        }
    }

    local arch = os.arch()
    local plat
    if is_host("windows") then
        plat = "windows"
        arch = arch == "x64" and "x86_64" or arch
    elseif is_host("linux") then
        plat = "linux"
        if arch:startswith("armv") then
            arch = "armhf"
        end
    elseif is_host("macosx") then
        plat = "macosx"
    end

    if plat and variants[plat] and variants[plat][arch] then
        local variant = variants[plat][arch]
        set_urls("https://github.com/espressif/esptool/releases/download/v$(version)/esptool-v$(version)-" .. variant.suffix)
        for v, h in pairs(variant.versions) do
            add_versions(v, h)
        end
    end

    on_install("windows|x64", "@linux", "@macosx", function (package)
        os.vcp("*|README.md|LICENSE", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrunv("esptool", {"version"})
    end)
