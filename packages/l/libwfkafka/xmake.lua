package("libwfkafka")
    set_homepage("https://github.com/sogou/workflow")
    set_description("C++ Workflow's Kafka Client")
    set_license("Apache-2.0")

    add_deps("workflow", {configs = {kafka = true}})

    on_install("linux", "macosx", "android", function (package)
        local workflow = package:dep("workflow")
        os.cp(path.join(workflow:installdir("lib"), "libwfkafka.a/so"), package:installdir("lib"))
        -- copy headerfiles
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("protocol::KafkaToppar", {configs = {languages = "c++11"}, includes = "KafkaMessage.h"}))
    end)
