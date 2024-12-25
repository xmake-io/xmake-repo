package("aws-c-compression")
    set_homepage("https://github.com/awslabs/aws-c-compression")
    set_description("C99 implementation of huffman encoding/decoding")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-compression/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-compression.git")

    add_versions("v0.3.0", "7e5d7308d1dbb1801eae9356ef65558f707edf33660dd6443c985db9474725eb")
    add_versions("v0.2.19", "51796f98a29a0d6e257c02e1f842bbc41db324758939093e6d46ec28337a3272")
    add_versions("v0.2.18", "517c361f3b7fffca08efd5ad251a20489794f056eab0dfffacc6d5b341df8e86")
    add_versions("v0.2.17", "703d1671e395ea26f8b0b70d678ed471421685a89e127f8aa125e2b2ecedb0e0")

    add_configs("asan", {description = "Enable Address Sanitize.", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake", "aws-c-common")

    on_install("windows|x64", "windows|x86", "linux", "macosx", "bsd", "msys", "android", "iphoneos", "cross", "wasm", function (package)
        local aws_cmakedir = package:dep("aws-c-common"):installdir("lib", "cmake")
        local aws_c_common_configdir = package:dep("aws-c-common"):installdir("lib", "aws-c-common", "cmake")
        if is_host("windows") then
            aws_cmakedir = aws_cmakedir:gsub("\\", "/")
            aws_c_common_configdir = aws_c_common_configdir:gsub("\\", "/")
        end

        local configs =
        {
            "-DBUILD_TESTING=OFF",
            "-DCMAKE_MODULE_PATH=" .. aws_cmakedir,
            "-Daws-c-common_DIR=" .. aws_c_common_configdir
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SANITIZERS=" .. (package:config("asan") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DAWS_STATIC_MSVC_RUNTIME_LIBRARY=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aws_huffman_encoder_init", {includes = "aws/compression/huffman.h"}))
    end)
