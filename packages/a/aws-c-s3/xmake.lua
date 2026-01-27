package("aws-c-s3")
    set_homepage("https://github.com/awslabs/aws-c-s3")
    set_description("C99 library implementation for communicating with the S3 service, designed for maximizing throughput on high bandwidth EC2 instances.")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-s3/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-s3.git")

    add_versions("v0.11.5", "bc76ad6e4ef40703477cd2e411553b85216def71a0073cfe8b7fad8d3728b37c")
    add_versions("v0.11.4", "4a2d34a92eafe66f0edfe2483ca4fb16c48b610bfc9cccb13b00108d587fe9c9")
    add_versions("v0.11.3", "b8350a10050015493345453167d619f1b407c4970fa3fe5aaaf2b42ab93b7b6b")
    add_versions("v0.11.2", "ef99f5f49ac65fe48f87d514ea751cb0c908126b0a6f45862b4525727bdb73dc")
    add_versions("v0.9.2", "70ddd1e69fed7788ff5499b03158f36fb8137d82bd7b1af7bcdf57facbdb1557")
    add_versions("v0.8.7", "bbe1159f089ac4e5ddcdf5ef96941489240a3f780c5e140f3c8462df45e787ac")
    add_versions("v0.8.6", "583fb207c20a2e68a8e2990d62668b96c9662cf864f7c13c87d9ede09d61f8e5")
    add_versions("v0.8.3", "c1c233317927091ee966bb297db2e6adbb596d6e5f981dbc724b0831b7e8f07d")
    add_versions("v0.8.1", "c8b09780691d2b94e50d101c68f01fa2d1c3debb0ff3aed313d93f0d3c9af663")
    add_versions("v0.7.15", "458b32811069e34186cfcef6c2d63a02b34657e70e880e1c0706976ce4b58389")
    add_versions("v0.7.14", "1a8cd98612f5d08ac12f1c0ab7235e1750faf8fb0e7680662101626b81963a66")
    add_versions("v0.7.12", "096ac66bc830c8a29cb12652db095e03a2ed5b15645baa4d7c78de419a0d6a54")
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

    add_configs("assert_lock_help", {description = "Enable ASSERT_SYNCED_DATA_LOCK_HELD for checking thread issue", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("aws-checksums", "aws-c-io", "aws-c-http", "aws-c-auth")

    on_install("!wasm and (!mingw or mingw|!i386)", function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "WIN32", "AWS_S3_USE_IMPORT_EXPORT")
        end

        local cmakedir = package:dep("aws-c-common"):installdir("lib/cmake")
        if is_host("windows") then
            cmakedir = cmakedir:gsub("\\", "/")
        end

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
        assert(package:has_cfuncs("aws_s3_library_init", {includes = "aws/s3/s3.h"}))
    end)
