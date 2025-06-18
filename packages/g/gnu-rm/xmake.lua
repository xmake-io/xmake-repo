package("gnu-rm")

    set_kind("toolchain")
    set_homepage("https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm")
    set_description("GNU Arm Embedded Toolchain")

    local version_map = {
        ["2020.10"] = "10-2020q4/gcc-arm-none-eabi-10-2020-q4-major",
        ["2021.10"] = "10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10",
        ["2024.12"] = "14.2.rel1"
    }

    if is_host("windows") then
        set_urls("https://developer.arm.com/-/media/Files/downloads/gnu-rm/$(version)-win32.zip", {version = function (version)
            return version_map[tostring(version)]
        end})
        add_versions("2020.10", "90057b8737b888c53ca5aee332f1f73c401d6d3873124d2c2906df4347ebef9e")
        add_versions("2021.10", "d287439b3090843f3f4e29c7c41f81d958a5323aecefcf705c203bfd8ae3f2e7")
        if os.arch() ~= "x64" then
            add_urls("https://developer.arm.com/-/media/Files/downloads/gnu/$(version)/binrel/arm-gnu-toolchain-$(version)-mingw-w64-i686-arm-none-eabi.zip", {version = function (version)
                return version_map[tostring(version)]
            end})
            add_versions("2024.12", "6facb152ce431ba9a4517e939ea46f057380f8f1e56b62e8712b3f3b87d994e1")
        else
            add_urls("https://developer.arm.com/-/media/Files/downloads/gnu/$(version)/binrel/arm-gnu-toolchain-$(version)-mingw-w64-x86_64-arm-none-eabi.zip", {version = function (version)
                return version_map[tostring(version)]
            end})
            add_versions("2024.12", "f074615953f76036e9a51b87f6577fdb4ed8e77d3322a6f68214e92e7859888f")
        end
    elseif is_host("linux") then
        if os.arch() == "arm64" then
            set_urls("https://developer.arm.com/-/media/Files/downloads/gnu-rm/$(version)-aarch64-linux.tar.bz2",
                "https://developer.arm.com/-/media/Files/downloads/gnu/$(version)/binrel/arm-gnu-toolchain-$(version)-aarch64-arm-none-eabi.tar.xz", {version = function (version)
                    return version_map[tostring(version)]
                end})
            add_versions("2020.10", "343d8c812934fe5a904c73583a91edd812b1ac20636eb52de04135bb0f5cf36a")
            add_versions("2021.10", "f605b5f23ca898e9b8b665be208510a54a6e9fdd0fa5bfc9592002f6e7431208")
            add_versions("2024.12", "87330bab085dd8749d4ed0ad633674b9dc48b237b61069e3b481abd364d0a684")
        else
            set_urls("https://developer.arm.com/-/media/Files/downloads/gnu-rm/$(version)-x86_64-linux.tar.bz2",
                "https://developer.arm.com/-/media/Files/downloads/gnu/$(version)/binrel/arm-gnu-toolchain-$(version)-x86_64-arm-none-eabi.tar.xz", {version = function (version)
                    return version_map[tostring(version)]
                end})
            add_versions("2020.10", "21134caa478bbf5352e239fbc6e2da3038f8d2207e089efc96c3b55f1edcd618")
            add_versions("2021.10", "97dbb4f019ad1650b732faffcc881689cedc14e2b7ee863d390e0a41ef16c9a3")
            add_versions("2024.12", "62a63b981fe391a9cbad7ef51b17e49aeaa3e7b0d029b36ca1e9c3b2a9b78823")
        end
    elseif is_host("macosx") and os.arch() ~= "arm64" then
        set_urls("https://developer.arm.com/-/media/Files/downloads/gnu-rm/$(version)-mac.tar.bz2",
            "https://developer.arm.com/-/media/Files/downloads/gnu/$(version)/binrel/arm-gnu-toolchain-$(version)-darwin-x86_64-arm-none-eabi.tar.xz", {version = function (version)
                return version_map[tostring(version)]
            end})
        add_versions("2020.10", "bed12de3565d4eb02e7b58be945376eaca79a8ae3ebb785ec7344e7e2db0bdc0")
        add_versions("2021.10", "fb613dacb25149f140f73fe9ff6c380bb43328e6bf813473986e9127e2bc283b")
        add_versions("2024.12", "2d9e717dd4f7751d18936ae1365d25916534105ebcb7583039eff1092b824505")
    elseif is_host("macosx")
        set_urls(
            "https://developer.arm.com/-/media/Files/downloads/gnu/$(version)/binrel/arm-gnu-toolchain-$(version)-darwin-arm64-arm-none-eabi.tar.xz", {version = function (version)
                return version_map[tostring(version)]
            end})
        add_versions("2024.12", "c7c78ffab9bebfce91d99d3c24da6bf4b81c01e16cf551eb2ff9f25b9e0a3818")
    end

    on_install("@windows", "@linux", "@macosx", function(package)
        os.vcp("*|manifest.txt", package:installdir())
    end)

    on_test(function (package)
        local gcc = "arm-none-eabi-gcc"
        if gcc and is_host("windows") then
            gcc = gcc .. ".exe"
        end
        os.vrunv(gcc, {"--version"})
    end)

