package("mono")

    set_homepage("https://www.mono-project.com/")
    set_description("Cross platform, open source .NET development framework")

    set_urls("https://download.mono-project.com/sources/mono/mono-$(version).tar.xz",
             {version = function (version) return version:gsub("%+", ".") end})

    add_versions("6.8.0+123", "e2e42d36e19f083fc0d82f6c02f7db80611d69767112af353df2f279744a2ac5")
    add_versions("6.12.0+182", "57366a6ab4f3b5ecf111d48548031615b3a100db87c679fc006e8c8a4efd9424")

    add_includedirs("include/mono-2.0")
    add_deps("cmake")

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-silent-rules", "--enable-nls=no"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mono_object_get_class", {includes = "mono/metadata/object.h"}))
    end)

