package("wyhash")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/wangyi-fudan/wyhash")
    set_description("The FASTEST QUALITY hash function, random number generators (PRNG) and hash map.")
    set_license("Unlicense")

    add_urls("https://github.com/wangyi-fudan/wyhash.git")
    add_versions("2023.04.10", "77e50f267fbc7b8e2d09f2d455219adb70ad4749")

    on_install(function (package)
        os.cp("old_versions", package:installdir("include"))
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("wyhash", {includes = "wyhash.h"}))
    end)
