package("aws-c-auth")
    set_homepage("https://github.com/awslabs/aws-c-auth")
    set_description("C99 library implementation of AWS client-side authentication: standard credentials providers and signing.")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-auth/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-auth.git")

    add_versions("v0.8.0", "217a0ebf8d7c5ad7e5f5ae814c2a371042164b64b4b9330c1c4bb2c6db1dbd33")
    add_versions("v0.7.31", "7f97aacef6bd1649734383c2bf022250671f353b7fa60d195e6865d7f4594b43")
    add_versions("v0.7.29", "f49f5dce1153e908dd9c0639f4aa4b1477f8564a28635f433cc0be121a18106e")
    add_versions("v0.7.25", "8f7993f8fad2992ca19c00123ea16e72c4d13acbeeb6333061034a299274f081")
    add_versions("v0.7.22", "f249a12a6ac319e929c005fb7efd5534c83d3af3a3a53722626ff60a494054bb")
    add_versions("v0.7.18", "c705199655066f1f874bc3758683f32e288024196a22f28360d336231e45406f")
    add_versions("v0.7.17", "8fe380255a71a2d5c9acd4979c135f9842135ce6385010ea562bc0b532bf5b84")
    add_versions("v0.7.3", "22e334508b76f1beddefbf877f200c8a5ace4e3956c6be6545b7572762afe8c5")

    add_configs("asan", {description = "Enable Address Sanitize.", default = false, type = "boolean"})
    add_configs("assert_lock_help", {description = "Enable ASSERT_SYNCED_DATA_LOCK_HELD for checking thread issue", default = false, type = "boolean"})

    add_deps("cmake", "aws-c-common", "aws-c-cal", "aws-c-io", "aws-c-sdkutils", "aws-c-http")

    on_install("windows|x64", "windows|x86", "linux", "macosx", "bsd", "msys", "cross", function (package)
        local cmakedir = package:dep("aws-c-common"):installdir("lib", "cmake")
        if package:is_plat("windows") then
            cmakedir = cmakedir:gsub("\\", "/")
        end

        local configs = {"-DBUILD_TESTING=OFF", "-DCMAKE_MODULE_PATH=" .. cmakedir}
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
