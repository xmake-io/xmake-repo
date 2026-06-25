package("libarchive")
    set_homepage("https://libarchive.org/")
    set_description("Multi-format archive and compression library")
    set_license("BSD-2-Clause")

    add_urls("https://libarchive.org/downloads/libarchive-$(version).tar.gz")

    add_versions("3.8.8", "038918ea315cdd446cc63acfe880d6011832bbe1711c887de5de5441b306c190")
    add_versions("3.8.7", "4b787cca6697a95c7725e45293c973c208cbdc71ae2279f30ef09f52472b9166")
    add_versions("3.8.6", "213269b05aac957c98f6e944774bb438d0bd168a2ec60b9e4f8d92035925821c")
    add_versions("3.8.5", "8a60f3a7bfd59c54ce82ae805a93dba65defd04148c3333b7eaa2102f03b7ffd")
    add_versions("3.8.4", "b2c75b132a0ec43274d2867221befcb425034cd038e465afbfad09911abb1abb")
    add_versions("3.7.7", "4cc540a3e9a1eebdefa1045d2e4184831100667e6d7d5b315bb1cbc951f8ddff")
    add_versions("3.7.2", "df404eb7222cf30b4f8f93828677890a2986b66ff8bf39dac32a804e96ddf104")
    add_versions("3.6.2", "ba6d02f15ba04aba9c23fd5f236bb234eab9d5209e95d1c4df85c44d5f19b9b3")
    add_versions("3.5.2", "5f245bd5176bc5f67428eb0aa497e09979264a153a074d35416521a5b8e86189")
    add_versions("3.5.1", "9015d109ec00bb9ae1a384b172bf2fc1dff41e2c66e5a9eeddf933af9db37f5a")

    add_deps("cmake")
    add_deps("zlib", "bzip2", "lz4", "zstd")

    add_configs("openssl3", {description = "Enable use of OpenSSL.", default = true, type = "boolean"})
    add_configs("lzma", {description = "Enable use of OpenSSL.", default = false, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("advapi32", "bcrypt", "ws2_32", "shlwapi", "user32", "crypt32")
    end

    on_load(function (package)
        if package:config("openssl3") then
            package:add("deps", "openssl3", {configs = {shared = package:config("shared")}})
        end
        if package:config("lzma") then
            package:add("deps", "lzma")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DENABLE_TEST=OFF",
                         "-DENABLE_CAT=OFF",
                         "-DENABLE_TAR=OFF",
                         "-DENABLE_CPIO=OFF",
                         "-DENABLE_PCREPOSIX=OFF",
                         "-DENABLE_LibGCC=OFF",
                         "-DENABLE_LIBGCC=OFF",
                         "-DENABLE_ICONV=OFF",
                         "-DENABLE_ACL=OFF",
                         "-DENABLE_EXPAT=OFF",
                         "-DENABLE_LIBXML2=OFF",
                         "-DENABLE_LIBB2=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_OPENSSL=" .. (package:config("openssl3") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_LZMA=" .. (package:config("lzma") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_CNG=" .. (package:is_plat("windows") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DPOSIX_REGEX_LIB=NONE")
        end
        if not package:config("shared") then
            package:add("defines", "LIBARCHIVE_STATIC")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("archive_version_number", {includes = "archive.h"}))
    end)
