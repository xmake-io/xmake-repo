package("xtensa-esp-elf")
    set_kind("toolchain")
    set_homepage("https://github.com/espressif/crosstool-NG")
    set_description("crosstool-NG with support for Xtensa")
    set_license("GPL-3.0-with-GCC-exception")

    local variants = {
        windows = {
            x86_64 = {suffix = "x86_64-w64-mingw32.zip", versions = {
                ["15.2.0"] = "efa1e337b5f64239674bf755b767969cbba7f4e66fe7c6ab8d19b650f56012a9",
                ["14.2.0"] = "9295d0d2f847c1424d81c88f0b4064bbc72224bf7b93a50d12893a99e13b154f"
            }},
            x86 = {suffix = "i686-w64-mingw32.zip", versions = {
                ["15.2.0"] = "72403f48827f75495f7c0b1c2be9f643c8dac25af7722545fc3ba1f21e834389",
                ["14.2.0"] = "7f11fe40a44968501802d92da54c4cd3d04208fd06ac40fcbcdcebf78f05b94d"
            }}
        },
        linux = {
            x86_64 = {suffix = "x86_64-linux-gnu.tar.xz", versions = {
                ["15.2.0"] = "3d50f5cd5f173acfd524e07c1cd69bc99585731a415ca2e5bce879997fe602b8",
                ["14.2.0"] = "041d42d3327bb4f28200896e65aa2e1a618b14bb79be0cd43b08a8b665c5f598"
            }},
            x86 = {suffix = "i586-linux-gnu.tar.xz", versions = {
                ["15.2.0"] = "6d3c510ddf5f084734c1dd5671d87a7b13973d713f641596ec1351dcce8d3ff3",
                ["14.2.0"] = "22ec70b7c8c39e76a3102e51536cc065fe832a9dcef17461ce56ccf6089fd02a"
            }},
            arm64 = {suffix = "aarch64-linux-gnu.tar.xz", versions = {
                ["15.2.0"] = "c8a8255009803036ba3def98a97a7134ee5a8ac5db048425e126fcf07f27ce1c",
                ["14.2.0"] = "bf27114cc3a5b39e6483ce665526c2831474ee5c350012bd85bbe910e46dee16"
            }},
            armel = {suffix = "arm-linux-gnueabi.tar.xz", versions = {
                ["15.2.0"] = "0ae215a8adb2823b370e31d20891747af42b86ce5042331df50829942d8cbbfe",
                ["14.2.0"] = "e24b1ba25cbdeb2298245e37e7985fc211b0d055902ed9983a9d7b41d32c2aec"
            }},
            armhf = {suffix = "arm-linux-gnueabihf.tar.xz", versions = {
                ["15.2.0"] = "99c1b5d45e9d661457d7a98494e5ebb2ed2e01b4b4dd4861de750acaec15a7bc",
                ["14.2.0"] = "e9bd7900776d82839b302a3a9676449b91066bd35f737c0621151fa4471c11dd"
            }}
        },
        macosx = {
            x86_64 = {suffix = "x86_64-apple-darwin.tar.xz", versions = {
                ["15.2.0"] = "96da1fcf01e2ac89819d1e336ca9e27762c35ea120627b89de8fd482f42c54f8",
                ["14.2.0"] = "5c59da5fcd6b41cbf27617a2d2d9ddd65add6da4269941171d956b1e129d15a5"
            }},
            arm64 = {suffix = "aarch64-apple-darwin.tar.xz", versions = {
                ["15.2.0"] = "68d3fb1e75c6bb1b88c6a2c74977abd51efd09b560a99149bafdcf403cb21941",
                ["14.2.0"] = "23ec3c967f7219c2ee25f84e6d4fdccf0ff89ca320622ba3d614b459213cae69"
            }}
        }
    }


    local plat
    if is_host("windows") then
        plat = "windows"
    elseif is_host("linux") then
        plat = "linux"
    elseif is_host("macosx") then
        plat = "macosx"
    end

    local arch = os.arch()
    if plat and variants[plat] and variants[plat][arch] then
        local variant = variants[plat][arch]
        set_urls("https://github.com/espressif/crosstool-NG/releases/download/esp-$(version)/xtensa-esp-elf-$(version)-" .. variant.suffix, {
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

    on_install("@windows", "@linux", "@macosx", function(package)
        os.cp("*", package:installdir())
    end)

    on_test(function (package)
        local gcc = "xtensa-esp-elf-gcc"
        if is_host("windows") then
            gcc = gcc .. ".exe"
        end
        os.vrunv(gcc, {"--version"})
    end)
