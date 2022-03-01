package("librdkafka")
    set_homepage("https://github.com/edenhill/librdkafka")
    set_description("The Apache Kafka C/C++ library")

    add_urls("https://github.com/edenhill/librdkafka/archive/refs/tags/$(version).tar.gz",
             "https://github.com/edenhill/librdkafka.git")
    add_versions("v1.6.2", "b9be26c632265a7db2fdd5ab439f2583d14be08ab44dc2e33138323af60c39db")
    add_versions("v1.8.2-POST2", "d556d07cb88ea689e28c8e058ec3265ab333c9fc5e8f4ac0b7509bb5ae0e9f25")

    if is_plat("windows", "mingw") then
        -- Do not build static library for window.
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})
    end

    -- lz4_ext means using external lz4 library instead of librdkafka's bundled one.
    -- When lz4_ext is disabled, we still need to link with external lz4 library.
    local config_default = {lz4_ext = true}
    local configdeps = {lz4_ext = "lz4", sasl = "cyrus-sasl", ssl = "openssl", zlib = "zlib", zstd = "std"}
    for config, dep in pairs(configdeps) do
        add_configs(config, {description = "Enable " .. config .. " support.", default = config_default[config] or false, type = "boolean"})
    end

    add_deps("cmake")

    add_links("rdkafka++", "rdkafka")

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
                if name == "sasl" then
                    package:add("syslinks", "sasl2")
                else
                    package:add("syslinks", dep)
                end
            end
        end
    end)

    on_install(function (package)
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
    end)

    on_test(function (package)
        assert(package:has_cfuncs("rd_kafka_produce", {includes = "librdkafka/rdkafka.h"}))
    end)
