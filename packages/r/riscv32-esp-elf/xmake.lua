package("riscv32-esp-elf")
    set_kind("toolchain")
    set_homepage("https://github.com/espressif/crosstool-NG")
    set_description("crosstool-NG with support for RISC-V (esp32c*/esp32h*/esp32p4)")
    set_license("GPL-3.0-with-GCC-exception")

    local variants = {
        windows = {
            x86_64 = {suffix = "x86_64-w64-mingw32.zip", versions = {
                ["15.2.0"] = "c61488aa15f49146aae918267110f775a52c3cef3844cbf261f475ef97523c3d",
                ["14.2.0"] = "74d1d2a018eea6705fa34d6c5387729b85843cb829a58b287cc6074a92f7184f"
            }},
            x86 = {suffix = "i686-w64-mingw32.zip", versions = {
                ["15.2.0"] = "a52d9c855f1771527d2a6b6a6012ddff3f17bb5c937830b163aa8418177c86da",
                ["14.2.0"] = "2a49a8dd4c6a59c1781c2ef59151e7cb5a2c677808904fe116d652f1dd6fef03"
            }}
        },
        linux = {
            x86_64 = {suffix = "x86_64-linux-gnu.tar.xz", versions = {
                ["15.2.0"] = "ace5aae6afe98f754947be043d40173e2e22ace57754b11a394b7238eefa01cf",
                ["14.2.0"] = "c0aee981f159a00cd33d4dd03a8b8e1d0c486f27815314c5c77f66aa92e703e9"
            }},
            x86 = {suffix = "i586-linux-gnu.tar.xz", versions = {
                ["15.2.0"] = "8dc31a97c008bf80d0c0b20b5960c522d9552f77a79ffd60e3ae6b1329cd68ef",
                ["14.2.0"] = "516b1716bee4025eb08379ee2744af6477787bb9c1ddb62f3f9465f8da67b263"
            }},
            arm64 = {suffix = "aarch64-linux-gnu.tar.xz", versions = {
                ["15.2.0"] = "90cccb3ef035f016836dd7c292528b27333a716d42b9361a68005d178c0f70bf",
                ["14.2.0"] = "5603027f6b0ffe1a06898ac17bb773071845088f8302f00bd80739ab08b5b96c"
            }},
            armel = {suffix = "arm-linux-gnueabi.tar.xz", versions = {
                ["15.2.0"] = "5603d18a0534ab5c2faca672ac890ad5b57727e55c6734adf6584aa73844f112",
                ["14.2.0"] = "6f84a1859b929382c4f427f7aa1a053412ca328a9394b3380aff13f637d733b7"
            }},
            armhf = {suffix = "arm-linux-gnueabihf.tar.xz", versions = {
                ["15.2.0"] = "61b2feebfe14c5f2a7966ccec0c1c7ed2e2840d260671730f376aa92323b1338",
                ["14.2.0"] = "52a282402b853905f2d18ef02b5d36c0b708f7e6f6886aecec26543b0705bcc1"
            }}
        },
        macosx = {
            x86_64 = {suffix = "x86_64-apple-darwin.tar.xz", versions = {
                ["15.2.0"] = "6d4709eadf4c66aecb51c0ff9c7b068eefa6ecec37aa7817f172c9f735318e73",
                ["14.2.0"] = "5322b2c94ab9fcb26582d58bb4f78cb527bdea60314ce956d7d88140c3ef6af7"
            }},
            arm64 = {suffix = "aarch64-apple-darwin.tar.xz", versions = {
                ["15.2.0"] = "0869d1083532c631808543dd802885f02dbe1bb3bd640be0dee827e82ded768d",
                ["14.2.0"] = "00d10c738f0493bc650c47cc67af800f0d6b827700504887a47e00c98ae121d5"
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
        -- os.arch() reports the raw host arch, e.g. i386/armv7a
        if arch == "i386" or arch == "i686" then
            arch = "x86"
        elseif arch:startswith("armv") then
            arch = "armhf"
        end
    elseif is_host("macosx") then
        plat = "macosx"
    end

    if plat and variants[plat] and variants[plat][arch] then
        local variant = variants[plat][arch]
        set_urls("https://github.com/espressif/crosstool-NG/releases/download/esp-$(version)/riscv32-esp-elf-$(version)-" .. variant.suffix, {
            version = function (version)
                local versions_date = {
                    ["15.2.0"] = "20251204",
                    ["14.2.0"] = "20251208"
                }
                return format("%s_%s", version, versions_date[tostring(version)])
            end
        })
        for v, h in pairs(variant.versions) do
            add_versions(v, h)
        end
    end

    on_install("windows|!arm*", "@linux", "@macosx", function(package)
        os.cp("*", package:installdir())
    end)

    on_test(function (package)
        local gcc = "riscv32-esp-elf-gcc"
        if is_host("windows") then
            gcc = gcc .. ".exe"
        end
        os.vrunv(gcc, {"--version"})
    end)
