package("libwfkafka")
    set_homepage("https://github.com/sogou/workflow")
    set_description("The Kafka Client of C++ Workflow")
    set_license("Apache-2.0")

    add_urls("https://github.com/sogou/workflow/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sogou/workflow.git")
    add_versions("v0.10.6", "3d32cb4240c7ec6835c5c0f0bbe8fe0cee38a53351b200facd436d5ff3e31bd1")
    
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

