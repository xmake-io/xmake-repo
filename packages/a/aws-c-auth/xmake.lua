package("aws-c-auth")
    set_homepage("https://github.com/awslabs/aws-c-auth")
    set_description("C99 library implementation of AWS client-side authentication: standard credentials providers and signing.")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-auth/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-auth.git")

    add_versions("v0.9.5", "39000bff55fe8c82265b9044a966ab37da5c192a775e1b68b6fcba7e7f9882fb")
    add_versions("v0.9.4", "704b2f965c31d9d0fd8d9ab207bc8c838e3683c56bd8407e472bbc8fa9f9a209")
    add_versions("v0.9.1", "adae1e725d9725682366080b8bf8e49481650c436b846ceeb5efe955d5e03273")
    add_versions("v0.9.0", "aa6e98864fefb95c249c100da4ae7aed36ba13a8a91415791ec6fad20bec0427")
    add_versions("v0.8.7", "b961cbed0b82248d3ea7a47f5a49bf174d5a0a977bbdd7ef3e1b2d2eb5468af5")
    add_versions("v0.8.6", "5f5df716d02a2b973ec685f1b50749b2e82736599189926817fbca00cfb194d7")
    add_versions("v0.8.0", "217a0ebf8d7c5ad7e5f5ae814c2a371042164b64b4b9330c1c4bb2c6db1dbd33")
    add_versions("v0.7.31", "7f97aacef6bd1649734383c2bf022250671f353b7fa60d195e6865d7f4594b43")
    add_versions("v0.7.29", "f49f5dce1153e908dd9c0639f4aa4b1477f8564a28635f433cc0be121a18106e")
    add_versions("v0.7.25", "8f7993f8fad2992ca19c00123ea16e72c4d13acbeeb6333061034a299274f081")
    add_versions("v0.7.22", "f249a12a6ac319e929c005fb7efd5534c83d3af3a3a53722626ff60a494054bb")
    add_versions("v0.7.18", "c705199655066f1f874bc3758683f32e288024196a22f28360d336231e45406f")
    add_versions("v0.7.17", "8fe380255a71a2d5c9acd4979c135f9842135ce6385010ea562bc0b532bf5b84")
    add_versions("v0.7.3", "22e334508b76f1beddefbf877f200c8a5ace4e3956c6be6545b7572762afe8c5")

    add_configs("assert_lock_help", {description = "Enable ASSERT_SYNCED_DATA_LOCK_HELD for checking thread issue", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("aws-c-io", "aws-c-sdkutils", "aws-c-http")

    on_install("!wasm and (!mingw or mingw|!i386)", function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "USE_WINDOWS_DLL_SEMANTICS", "AWS_AUTH_USE_IMPORT_EXPORT")
        end

        local cmakedir = path.unix(package:dep("aws-c-common"):installdir("lib", "cmake"))

        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
            "-DCMAKE_MODULE_PATH=" .. cmakedir,
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SANITIZERS=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DASSERT_LOCK_HELD=" .. (package:config("assert_lock_help") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DAWS_STATIC_MSVC_RUNTIME_LIBRARY=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aws_auth_library_init", {includes = "aws/auth/auth.h"}))
    end)
