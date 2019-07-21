package("icu4c")

    set_homepage("https://ssl.icu-project.org/")
    set_description("C/C++ libraries for Unicode and globalization.")

    add_urls("https://ssl.icu-project.org/files/icu4c/$(version)-src.tgz", {version = function (version)
            return version .. "/icu4c-" .. (version:gsub("%.", "_"))
        end})
    add_urls("https://github.com/unicode-org/icu/releases/download/release-$(version)-src.tgz", {version = function (version)
            return (version:gsub("%.", "-")) .. "/icu4c-" .. (version:gsub("%.", "_"))
        end})

    add_versions("64.2", "627d5d8478e6d96fc8c90fed4851239079a561a6a8b9e48b0892f24e82d31d6c")

    add_links("icuuc", "icutu", "icui18n", "icuio", "icudata")
    if is_plat("linux") then
        add_syslinks("dl")
    end

    on_install("macosx", "linux", function (package)
        os.cd("source")
        import("package.tools.autoconf").install(package, {"--disable-samples", "--disable-tests", "--enable-static", "--disable-shared"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ucnv_convert", {includes = "unicode/ucnv.h"}))
    end)
