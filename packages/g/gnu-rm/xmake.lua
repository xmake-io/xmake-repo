package("gnu-rm")

    set_kind("toolchain")
    set_homepage("https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm")
    set_description("GNU Arm Embedded Toolchain")

    local version_map = {
        ["2020.10"] = "10-2020q4/gcc-arm-none-eabi-2020.10-major",
        ["2021.10"] = "10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10"
    }

    if is_host("windows") then
        set_urls("https://developer.arm.com/-/media/Files/downloads/gnu-rm/$(version)-win32.zip", {version = function (version)
            return version_map[tostring(version)]
        end})
        add_versions("2020.10", "90057b8737b888c53ca5aee332f1f73c401d6d3873124d2c2906df4347ebef9e")
        add_versions("2021.10", "d287439b3090843f3f4e29c7c41f81d958a5323aecefcf705c203bfd8ae3f2e7")
    elseif is_host("linux") then
        if os.arch() == "arm64" then
            set_urls("https://developer.arm.com/-/media/Files/downloads/gnu-rm/$(version)-aarch64-linux.tar.bz2", {version = function (version)
                return version_map[tostring(version)]
            end})
            add_versions("2020.10", "343d8c812934fe5a904c73583a91edd812b1ac20636eb52de04135bb0f5cf36a")
            add_versions("2021.10", "f605b5f23ca898e9b8b665be208510a54a6e9fdd0fa5bfc9592002f6e7431208")
        else
            set_urls("https://developer.arm.com/-/media/Files/downloads/gnu-rm/$(version)-x86_64-linux.tar.bz2", {version = function (version)
                return version_map[tostring(version)]
            end})
            add_versions("2020.10", "21134caa478bbf5352e239fbc6e2da3038f8d2207e089efc96c3b55f1edcd618")
            add_versions("2021.10", "97dbb4f019ad1650b732faffcc881689cedc14e2b7ee863d390e0a41ef16c9a3")
        end
    elseif is_host("macosx") then
        set_urls("https://developer.arm.com/-/media/Files/downloads/gnu-rm/$(version)-mac.tar.bz2", {version = function (version)
            return version_map[tostring(version)]
        end})
        add_versions("2020.10", "bed12de3565d4eb02e7b58be945376eaca79a8ae3ebb785ec7344e7e2db0bdc0")
        add_versions("2021.10", "fb613dacb25149f140f73fe9ff6c380bb43328e6bf813473986e9127e2bc283b")
    end

    on_install("@windows", "@linux", "@macosx", function (package)
        os.vcp("*", package:installdir())
    end)

    on_test(function (package)
        local gcc = "arm-none-eabi-gcc"
        if gcc and is_host("windows") then
            gcc = gcc .. ".exe"
        end
        os.vrunv(gcc, {"--version"})
    end)

