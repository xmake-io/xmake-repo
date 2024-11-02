package("boost-cmake")
    set_homepage("https://www.boost.org/")
    set_description("Collection of portable C++ source libraries.")
    set_license("BSL-1.0")

    set_urls("https://github.com/boostorg/boost/releases/download/boost-$(version)/boost-$(version)-cmake.7z")

    add_versions("1.86.0", "ee6e0793b5ec7d13e7181ec05d3b1aaa23615947295080e4b9930324488e078f")

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
