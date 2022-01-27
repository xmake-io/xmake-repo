package("libsv")
    set_homepage("https://github.com/uael/sv")
    set_description("libsv - Public domain cross-platform semantic versioning in c99")

    add_urls("https://github.com/uael/sv.git")
    add_versions("2021.11.27", "10ee6a807466a5e61309201caea360a113ad3862")

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("semver(0,0)", {includes = "semver.h"}))
    end)
