package("aarch32_bare-metal_gnu_toolchain")
    set_kind("toolchain")
    set_homepage("https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain")
    set_description("GNU Arm Embedded Toolchain")

    local version_map = {
        ["14.2.1"] = "14.2.rel1"
    }

    if is_host("windows") then
        if is_arch("x64") then
            set_urls(
                "https://developer.arm.com/-/media/Files/downloads/gnu/$(version)/binrel/arm-gnu-toolchain-$(version)-mingw-w64-x86_64-arm-none-eabi.zip", {version = function (version)
                    return version_map[tostring(version)]
                end})
            add_versions("14.2.1", "f074615953f76036e9a51b87f6577fdb4ed8e77d3322a6f68214e92e7859888f")
        else
            set_urls(
                "https://developer.arm.com/-/media/Files/downloads/gnu/$(version)/binrel/arm-gnu-toolchain-$(version)-mingw-w64-i686-arm-none-eabi.zip", {version = function (version)
                    return version_map[tostring(version)]
                end})
            add_versions("14.2.1", "6facb152ce431ba9a4517e939ea46f057380f8f1e56b62e8712b3f3b87d994e1")
        end
    elseif is_host("linux") then
        if is_arch("arm64") then
            set_urls(
                "https://developer.arm.com/-/media/Files/downloads/gnu/$(version)/binrel/arm-gnu-toolchain-$(version)-aarch64-arm-none-eabi.tar.xz", {version = function (version)
                    return version_map[tostring(version)]
                end})
            add_versions("14.2.1", "87330bab085dd8749d4ed0ad633674b9dc48b237b61069e3b481abd364d0a684")
        else
            set_urls(
                "https://developer.arm.com/-/media/Files/downloads/gnu/$(version)/binrel/arm-gnu-toolchain-$(version)-x86_64-arm-none-eabi.tar.xz", {version = function (version)
                    return version_map[tostring(version)]
                end})
            add_versions("14.2.1", "62a63b981fe391a9cbad7ef51b17e49aeaa3e7b0d029b36ca1e9c3b2a9b78823")
        end
    elseif is_host("macosx") then
        if is_arch("arm64") then
            set_urls(
                "https://developer.arm.com/-/media/Files/downloads/gnu/$(version)/binrel/arm-gnu-toolchain-$(version)-darwin-arm64-arm-none-eabi.tar.xz", {version = function (version)
                    return version_map[tostring(version)]
                end})
            add_versions("14.2.1", "c7c78ffab9bebfce91d99d3c24da6bf4b81c01e16cf551eb2ff9f25b9e0a3818")
        else
            set_urls(
                "https://developer.arm.com/-/media/Files/downloads/gnu/$(version)/binrel/arm-gnu-toolchain-$(version)-darwin-x86_64-arm-none-eabi.tar.xz", {version = function (version)
                    return version_map[tostring(version)]
                end})
            add_versions("14.2.1", "2d9e717dd4f7751d18936ae1365d25916534105ebcb7583039eff1092b824505")
        end
    end

    on_install("@windows", "@linux", "@macosx", function(package)
        os.vcp("*|manifest.txt", package:installdir())
    end)

    on_test(function(package)
        local gcc = "arm-none-eabi-gcc"
        if gcc and is_host("windows") then
            gcc = gcc .. ".exe"
        end
        os.vrunv(gcc, { "--version" })
    end)
