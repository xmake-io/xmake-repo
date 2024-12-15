package("aws-c-s3")
    set_homepage("https://github.com/awslabs/aws-c-s3")
    set_description("C99 library implementation for communicating with the S3 service, designed for maximizing throughput on high bandwidth EC2 instances.")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-s3/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-s3.git")

    add_versions("v0.7.7", "843571de8cd504428bd4ef9ff574e3c91b51ae010813111757e1cfca951cf35e")
    add_versions("v0.7.5", "d2f68e8a8e9a9e9b16aecd4ae72d78860e3d71d6fe9ccd8f2d50a7ee5faf5619")
    add_versions("v0.7.4", "0e315694c524aece68da9327ab1c57f5d5dd9aed843fea3950429bb7cec70f35")
    add_versions("v0.7.1", "0723610c85262b2ac19be0bd98622857f09edc3317be707f6cfe9a9849796ef4")
    add_versions("v0.7.0", "d7a7dc82988221a1e7038a3ba1b4454c91dd66e41c08f2a83455d265d8683818")
    add_versions("v0.6.5", "b671006ae2b5c1302e49ca022e0f9e6504cfe171d9e47c3e59c52b2ab8e80ef5")
    add_versions("v0.6.0", "0a29dbb13ea003de3fd0d08a61fa705b1c753db4b35de9c464641432000f13ec")
    add_versions("v0.5.9", "7a337195b295406658d163b6dac64ff81f7556291b8a8e79e58ebaa2d55178ee")
    add_versions("v0.5.7", "2f2eab9bf90a319030fd3525953dc7ac00c8dc8c0d33e3f0338f2a3b554d3b6a")
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
