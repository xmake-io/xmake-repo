package("libarchive")

    set_homepage("https://libarchive.org/")
    set_description("Multi-format archive and compression library")
    set_license("BSD-2-Clause")

    add_urls("https://libarchive.org/downloads/libarchive-$(version).tar.gz")
    add_versions("3.5.1", "9015d109ec00bb9ae1a384b172bf2fc1dff41e2c66e5a9eeddf933af9db37f5a")

    add_deps("cmake")
    add_deps("zlib", "bzip2", "lz4")
    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DENABLE_TEST=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("archive_version_number", {includes = "archive.h"}))
    end)
