package("gnu-rm")

    set_kind("binary")
    set_homepage("https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm")
    set_description("GNU Arm Embedded Toolchain")

    if is_host("windows") then
        set_urls("https://developer.arm.com/-/media/Files/downloads/gnu-rm/$(version)-major-win32.zip", {version = function (version)
            return version:gsub("%-", ""):gsub("%.", "-") .. "/gcc-arm-none-eabi-" .. version:gsub("%.", "-")
        end})
        add_versions("10.2020-q4", "90057b8737b888c53ca5aee332f1f73c401d6d3873124d2c2906df4347ebef9e")
    elseif is_host("linux") then
        if os.arch() == "arm64" then
            set_urls("https://developer.arm.com/-/media/Files/downloads/gnu-rm/$(version)-major-aarch64-linux.tar.bz2", {version = function (version)
                return version:gsub("%-", ""):gsub("%.", "-") .. "/gcc-arm-none-eabi-" .. version:gsub("%.", "-")
            end})
            add_versions("10.2020-q4", "343d8c812934fe5a904c73583a91edd812b1ac20636eb52de04135bb0f5cf36a")
        else
            set_urls("https://developer.arm.com/-/media/Files/downloads/gnu-rm/$(version)-major-x86_64-linux.tar.bz2", {version = function (version)
                return version:gsub("%-", ""):gsub("%.", "-") .. "/gcc-arm-none-eabi-" .. version:gsub("%.", "-")
            end})
            add_versions("10.2020-q4", "21134caa478bbf5352e239fbc6e2da3038f8d2207e089efc96c3b55f1edcd618")
        end
    elseif is_host("macosx") then
        set_urls("https://developer.arm.com/-/media/Files/downloads/gnu-rm/$(version)-major-mac.tar.bz2", {version = function (version)
            return version:gsub("%-", ""):gsub("%.", "-") .. "/gcc-arm-none-eabi-" .. version:gsub("%.", "-")
        end})
        add_versions("10.2020-q4", "bed12de3565d4eb02e7b58be945376eaca79a8ae3ebb785ec7344e7e2db0bdc0")
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
