package("librdkafka")
    set_homepage("https://github.com/edenhill/librdkafka")
    set_description("The Apache Kafka C/C++ library")

    add_urls("https://github.com/edenhill/librdkafka/archive/refs/tags/$(version).tar.gz",
             "https://github.com/edenhill/librdkafka.git")
    add_versions("v1.6.2", "b9be26c632265a7db2fdd5ab439f2583d14be08ab44dc2e33138323af60c39db")

    add_configs("ssl", { description = "Enable ssl.", default = false, type = "boolean"})

    add_deps("cmake")

    add_links("rdkafka++", "rdkafka")

    on_load(function (package)
        if package:config("ssl") then
            package:add("deps", "openssl")
        end
    end)

    on_install("linux", "macosx", "windows", "cross", function (package)
        local configs = {"-DRDKAFKA_BUILD_EXAMPLES=OFF", "-DRDKAFKA_BUILD_TESTS=OFF"}
        table.insert(configs, "-DWITH_SSL=" .. (package:config("ssl") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("rd_kafka_produce", {includes = "librdkafka/rdkafka.h"}))
    end)
