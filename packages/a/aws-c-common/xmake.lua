package("aws-c-common")
    set_homepage("https://github.com/awslabs/aws-c-common")
    set_description("Core c99 package for AWS SDK for C")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-common/archive/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-common.git")
    add_versions("v0.6.9", "928a3e36f24d1ee46f9eec360ec5cebfe8b9b8994fe39d4fa74ff51aebb12717")

    if is_plat("linux") then
        add_deps("cmake")
        add_syslinks("dl", "m", "pthread", "rt")
    end

    on_install("linux", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DPERFORM_HEADER_CHECK=ON")
        table.insert(configs, "-DENABLE_NET_TESTS=OFF")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aws_common_library_init", {includes = "aws/common/common.h"}))
        assert(package:has_cfuncs("aws_common_library_clean_up", {includes = "aws/common/common.h"}))
        assert(package:has_cfuncs("aws_ring_buffer_init", {includes = "aws/common/ring_buffer.h"}))
        assert(package:has_cfuncs("aws_uuid_init", {includes = "aws/common/uuid.h"}))
    end)
