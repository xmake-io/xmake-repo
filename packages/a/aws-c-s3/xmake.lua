package("aws-c-s3")
    set_homepage("https://github.com/awslabs/aws-c-s3")
    set_description("C99 library implementation for communicating with the S3 service, designed for maximizing throughput on high bandwidth EC2 instances.")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-s3/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-s3.git")

    add_versions("v0.3.17", "72fd93a2f9a7d9f205d66890da249944b86f9528216dc0321be153bf19b2ecd5")

    add_configs("asan", {description = "Enable Address Sanitize.", default = false, type = "boolean"})
    add_configs("assert_lock_help", {description = "Enable ASSERT_SYNCED_DATA_LOCK_HELD for checking thread issue", default = false, type = "boolean"})

    add_deps("cmake", "aws-c-common", "aws-checksums", "aws-c-io", "aws-c-http", "aws-c-auth")

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
        assert(package:has_cfuncs("aws_s3_library_init", {includes = "aws/s3/s3.h"}))
    end)
