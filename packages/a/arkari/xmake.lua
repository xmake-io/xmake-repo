package("arkari")
    set_kind("toolchain")
    set_homepage("https://github.com/KomiMoe/Arkari")
    set_description("Yet another llvm based obfuscator based on goron.")
    set_license("Apache-2.0")

    local version_map = {
        ["19.1.3"] = "1.6.0"
    }

    add_urls("https://github.com/KomiMoe/Arkari/releases/download/$(version)/$(version).7z", {version = function (version)
        local llvm_ver = tostring(version)
        local obf_ver = version_map[llvm_ver]
        return string.format("Win64-MT-%s-obf%s", llvm_ver, obf_ver)
    end})

    add_versions("19.1.3", "9a181798ef3648cf8acb2f83941792f948d589a94b9d579a783b97331770ce93")

    on_install("windows|x64", function (package)
        os.mv("*", package:installdir())
    end)

    on_test(function (package)
        os.vrun("llvm-config --version")
    end)
