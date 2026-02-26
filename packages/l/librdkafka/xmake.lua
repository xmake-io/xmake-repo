package("librdkafka")
    set_homepage("https://docs.confluent.io/platform/current/clients/librdkafka/html/index.html")
    set_description("The Apache Kafka C/C++ library")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/confluentinc/librdkafka/archive/refs/tags/$(version).tar.gz",
             "https://github.com/confluentinc/librdkafka.git")
    add_versions("v2.13.0", "3bd351601d8ebcbc99b9a1316cae1b83b00edbcf9411c34287edf1791c507600")
    add_versions("v2.12.1", "ec103fa05cb0f251e375f6ea0b6112cfc9d0acd977dc5b69fdc54242ba38a16f")
    add_versions("v2.11.1", "a2c87186b081e2705bb7d5338d5a01bc88d43273619b372ccb7bb0d264d0ca9f")
    add_versions("v1.6.2", "b9be26c632265a7db2fdd5ab439f2583d14be08ab44dc2e33138323af60c39db")
    add_versions("v1.8.2-POST2", "d556d07cb88ea689e28c8e058ec3265ab333c9fc5e8f4ac0b7509bb5ae0e9f25")
    add_versions("v2.11.0", "592a823dc7c09ad4ded1bc8f700da6d4e0c88ffaf267815c6f25e7450b9395ca")

    if is_plat("windows", "mingw") then
        -- Do not build static library for window.
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
        add_configs("runtimes", {description = "Set vs compiler runtime.", default = "MD", readonly = true})
    end

    -- lz4_ext means using external lz4 library instead of librdkafka's bundled one.
    -- When lz4_ext is disabled, we still need to link with external lz4 library.
    local config_default = {lz4_ext = true, curl = true}
    local configdeps = {lz4_ext = "lz4", sasl = "cyrus-sasl", ssl = "openssl", zlib = "zlib", zstd = "zstd", curl = "libcurl"}
    for config, dep in pairs(configdeps) do
        add_configs(config, {description = "Enable " .. config .. " support.", default = config_default[config] or false, type = "boolean"})
    end

    add_deps("cmake")

    add_links("rdkafka++", "rdkafka")

    if on_check then
        on_check("iphoneos", function (package)
            assert(package:version():lt("2.13.0"), "package(librdkafka >= v2.13.0): unsupport iOS")
        end)
    end

    -- These syslinks come from PKG_CONFIG_LIBS_PRIVATE in librdkafka/src/CMakeLists.txt
    if is_plat("linux") or is_plat("bsd") then
        add_syslinks("pthread", "dl")
    elseif is_plat("mingw", "windows") then
        add_syslinks("ws2_32", "secur32", "crypt32")
    end

    on_load(function (package)
        for name, dep in pairs(configdeps) do
            if package:config(name) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("!wasm and !bsd", function (package)
        local configs = {
            "-DRDKAFKA_BUILD_EXAMPLES=OFF",
            "-DRDKAFKA_BUILD_TESTS=OFF",
            "-DWITH_BUNDLED_SSL=OFF",
        }
        table.insert(configs, "-DWITH_SSL=" .. (package:config("ssl") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DRDKAFKA_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        for config, dep in pairs(configdeps) do
            table.insert(configs, "-DWITH_" .. config:upper()  .. "=" .. (package:config(config) and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)

        if package:version():startswith("v1.8.2") then
            io.replace(path.join(package:installdir("lib"), "cmake", "RdKafka", "RdKafkaConfig.cmake"),
                "find_dependency(LZ4)",
                'list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_LIST_DIR}")\n  find_dependency(LZ4)\n  list(REMOVE_AT CMAKE_MODULE_PATH 0)',
                {plain = true})
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("rd_kafka_produce", {includes = "librdkafka/rdkafka.h"}))
    end)
