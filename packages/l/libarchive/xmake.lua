package("libarchive")
    set_homepage("https://libarchive.org/")
    set_description("Multi-format archive and compression library")
    set_license("BSD-2-Clause")

    add_urls("https://libarchive.org/downloads/libarchive-$(version).tar.gz")

    add_versions("3.8.5", "8a60f3a7bfd59c54ce82ae805a93dba65defd04148c3333b7eaa2102f03b7ffd")
    add_versions("3.8.4", "b2c75b132a0ec43274d2867221befcb425034cd038e465afbfad09911abb1abb")
    add_versions("3.7.7", "4cc540a3e9a1eebdefa1045d2e4184831100667e6d7d5b315bb1cbc951f8ddff")
    add_versions("3.7.2", "df404eb7222cf30b4f8f93828677890a2986b66ff8bf39dac32a804e96ddf104")
    add_versions("3.6.2", "ba6d02f15ba04aba9c23fd5f236bb234eab9d5209e95d1c4df85c44d5f19b9b3")
    add_versions("3.5.2", "5f245bd5176bc5f67428eb0aa497e09979264a153a074d35416521a5b8e86189")
    add_versions("3.5.1", "9015d109ec00bb9ae1a384b172bf2fc1dff41e2c66e5a9eeddf933af9db37f5a")

    add_deps("cmake")
    add_deps("zlib", "bzip2", "lz4", "zstd", "lzma")

    if is_plat("windows") then
        add_syslinks("advapi32")
    end

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DENABLE_TEST=OFF",
                         "-DENABLE_CAT=OFF",
                         "-DENABLE_TAR=OFF",
                         "-DENABLE_CPIO=OFF",
                         "-DENABLE_OPENSSL=OFF",
                         "-DENABLE_PCREPOSIX=OFF",
                         "-DENABLE_LibGCC=OFF",
                         "-DENABLE_CNG=OFF",
                         "-DENABLE_ICONV=OFF",
                         "-DENABLE_ACL=OFF",
                         "-DENABLE_EXPAT=OFF",
                         "-DENABLE_LIBXML2=OFF",
                         "-DENABLE_LIBB2=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if not package:config("shared") then
            package:add("defines", "LIBARCHIVE_STATIC")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("archive_version_number", {includes = "archive.h"}))
    end)
