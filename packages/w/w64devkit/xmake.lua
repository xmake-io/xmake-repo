package("w64devkit")
    set_kind("toolchain")
    set_homepage("https://github.com/skeeto/w64devkit")
    set_description("Portable C and C++ Development Kit for x64 (and x86) Windows")
    set_license("Unlicense")

    if os.arch() == "x64" then
        add_urls("https://github.com/skeeto/w64devkit/releases/download/v$(version)/w64devkit-x64-$(version).exe")

        add_versions("2.0.0", "cea23fc56a5e61457492113a8377c8ab0c42ed82303fcc454ccd1963a46f8ce1")
    elseif os.arch() == "x86" then
        add_urls("https://github.com/skeeto/w64devkit/releases/download/v$(version)/w64devkit-x86-$(version).exe")

        add_versions("2.0.0", "20ad6ef39c6b5fa0a0f49ec11891224a5856071976f4cb4042106a2451feef61")
    end

    on_install("@windows|x64", function (package)
        local archive = format("../w64devkit-%s-%s.exe", package:arch(), package:version_str())
        os.vrunv("7z", {"x", archive, "-o."})
        os.cp("w64devkit/*", package:installdir())
    end)

    on_test(function (package)
        os.vrunv(package:installdir("bin/x86_64-w64-mingw32-gcc.exe"), {"--version"})
    end)
