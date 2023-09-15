package("libarchive")

    set_homepage("https://libarchive.org/")
    set_description("Multi-format archive and compression library")
    set_license("BSD-2-Clause")

    add_urls("https://libarchive.org/downloads/libarchive-$(version).tar.gz")
    add_versions("3.5.1", "9015d109ec00bb9ae1a384b172bf2fc1dff41e2c66e5a9eeddf933af9db37f5a")
    add_versions("3.5.2", "5f245bd5176bc5f67428eb0aa497e09979264a153a074d35416521a5b8e86189")
    add_versions("3.6.2", "ba6d02f15ba04aba9c23fd5f236bb234eab9d5209e95d1c4df85c44d5f19b9b3")

    add_deps("cmake")
    add_deps("zlib", "bzip2", "lz4", "zstd")
    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DENABLE_TEST=OFF", "-DENABLE_OPENSSL=OFF", "-DENABLE_PCREPOSIX=OFF", "-DENABLE_LibGCC=OFF", "-DENABLE_CNG=OFF", "-DENABLE_ICONV=OFF", "-DENABLE_ACL=OFF", "-DENABLE_EXPAT=OFF", "-DENABLE_LIBXML2=OFF", "-DENABLE_LIBB2=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("archive_version_number", {includes = "archive.h"}))
    end)
