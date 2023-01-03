package("libwfkafka")
    set_homepage("https://github.com/sogou/workflow")
    set_description("The Kafka Client of C++ Workflow")
    set_license("Apache-2.0")

    add_urls("https://github.com/sogou/workflow/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sogou/workflow.git")
    add_versions("v0.9.11", "71b5531728d6b4f3666176dbc45d680350518af8")
    add_versions("v0.10.1", "315eb1b1b5411e807e5ecc45ba5aa7db1d4f7c28")
    add_versions("v0.10.2", "42d87f4f9eaa80e882ccdd71cd81d20899050266")
    add_versions("v0.10.3", "116e6772cd13b88a3fb8420bcfbef98921252a1a")
    add_versions("v0.10.4", "83d6346ca2c1bcd003f67100a4c77418f8acfed5")
    add_versions("v0.10.5", "4216034831c142bb9be9a9ca781dea737c606919")

    add_deps("cmake", "openssl", "workflow", "lz4", "zstd", "snappy", "zlib")

    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    add_links("wfkafka")

    on_install("linux", "macosx", function (package)
        local configs = {"-DKAFKA=y"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        local packagedeps = {"workflow", "lz4", "zstd", "snappy", "zlib"}
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"), "*.a"))
        else
            os.tryrm(path.join(package:installdir("lib"), "*.so"))
            os.tryrm(path.join(package:installdir("lib"), "*.dylib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("protocol::KafkaToppar", {configs = {languages = "c++11"}, includes = "workflow/KafkaMessage.h"}))
    end)
