package("libwfkafka")
    set_homepage("https://github.com/sogou/workflow")
    set_description("The Kafka Client of C++ Workflow")
    set_license("Apache-2.0")

    add_urls("https://github.com/sogou/workflow/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sogou/workflow.git")

    add_versions("v0.10.6", "5701ef31518a7927e61b26cd6cc1d699cb43393bf1ffc77fa61e73e64d2dd28e")
    add_versions("v0.10.7", "aa9806983f32174597549db4a129e2ee8a3d1f005923fcbb924906bc70c0e123")
    add_versions("v0.10.8", "bb5654e8011822d4251a7a433cbe4c5ecfd2c65c8f997a8196685742d24bcaf0")

    add_deps("openssl", "workflow", "lz4", "zstd", "snappy", "zlib")

    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    on_install("linux", "macosx", "android", function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        local packagedeps = {"workflow", "lz4", "zstd", "snappy", "zlib"}
        import("package.tools.xmake").install(package, configs, {packagedeps = packagedeps})
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

