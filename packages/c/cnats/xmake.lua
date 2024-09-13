package("cnats")
    set_homepage("https://github.com/nats-io/nats.c")
    set_description("A C client for NATS")
    set_license("Apache-2.0")

    add_urls("https://github.com/nats-io/nats.c/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nats-io/nats.c.git")

    add_versions("v3.8.2", "083ee03cf5a413629d56272e88ad3229720c5006c286e8180c9e5b745c10f37d")

    add_configs("tls", {description = "Build with TLS support", default = false, type = "boolean"})
    add_configs("sodium", {description = "Build with libsodium", default = false, type = "boolean"})
    add_configs("streaming", {description = "Build NATS Streaming", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread", "rt")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("tls") then
            package:add("deps", "openssl3")
        end
        if package:config("sodium") then
            package:add("deps", "libsodium")
        end
        if package:config("streaming") then
            package:add("deps", "protobuf-c")
            package:add("defines", "NATS_HAS_STREAMING")
        end
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "nats_IMPORTS")
        end
    end)

    on_install("!bsd", function (package)
        local configs = {"-DNATS_BUILD_EXAMPLES=OFF", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DNATS_BUILD_LIB_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DNATS_BUILD_LIB_STATIC=" .. (package:config("shared") and "OFF" or "ON"))

        table.insert(configs, "-DNATS_BUILD_STREAMING=" .. (package:config("streaming") and "ON" or "OFF"))
        table.insert(configs, "-DNATS_BUILD_TLS_USE_OPENSSL_1_1_API=ON")
        table.insert(configs, "-DNATS_BUILD_WITH_TLS=" .. (package:config("tls") and "ON" or "OFF"))
        table.insert(configs, "-DNATS_BUILD_USE_SODIUM=" .. (package:config("sodium") and "ON" or "OFF"))

        local cxflags
        if package:config("sodium") then
            local libsodium = package:dep("libsodium")
            if not libsodium:is_system() then
                table.insert(configs, "-DNATS_SODIUM_DIR=" .. libsodium:installdir())
                io.replace("CMakeLists.txt", "libsodium.lib libsodium.dll", "sodium.lib sodium.dll", {plain = true})
            end
            if not libsodium:config("shared") then
                cxflags = "-DSODIUM_STATIC"
            end
        end
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nats_GetVersion", {includes = "nats/nats.h"}))
    end)
