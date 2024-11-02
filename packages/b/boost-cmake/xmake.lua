package("boost-cmake")
    set_homepage("https://www.boost.org/")
    set_description("Collection of portable C++ source libraries.")
    set_license("BSL-1.0")

    set_urls("https://github.com/boostorg/boost/releases/download/boost-$(version)/boost-$(version)-cmake.tar.gz")

    add_versions("1.86.0", "c62ce6e64d34414864fef946363db91cea89c1b90360eabed0515f0eda74c75c")

    includes(path.join(os.scriptdir(), "libs.lua"))
    for libname, _ in pairs(get_libs()) do
        add_configs(libname, {description = "Enable " .. libname .. " library.", default = (libname == "filesystem"), type = "boolean"})
    end
    add_configs("zlib", {description = "Enable zlib for iostreams", default = false, type = "boolean"})
    add_configs("bzip2", {description = "Enable bzip2 for iostreams", default = false, type = "boolean"})
    add_configs("lzma", {description = "Enable lzma for iostreams", default = false, type = "boolean"})
    add_configs("zstd", {description = "Enable zstd for iostreams", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        import("cmake.load")(package)
    end)

    on_install(function (package)
        import("cmake.install")(package)
    end)

    on_test(function (package)
        import("test")(package)
    end)
