package("aws-c-compression")
    set_homepage("https://github.com/awslabs/aws-c-compression")
    set_description("C99 implementation of huffman encoding/decoding")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-compression/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-compression.git")

    add_versions("v0.2.17", "703d1671e395ea26f8b0b70d678ed471421685a89e127f8aa125e2b2ecedb0e0")

    add_configs("asan", {description = "Enable Address Sanitize.", default = false, type = "boolean"})

    add_deps("cmake", "aws-c-common")

    on_install("windows|x64", "windows|x86", "linux", "macosx", "bsd", "msys", "android", "iphoneos", "cross", "wasm", function (package)
        local cmakedir = package:dep("aws-c-common"):installdir("lib", "cmake")
        if package:is_plat("windows") then
            cmakedir = cmakedir:gsub("\\", "/")
        end

        local configs = {"-DBUILD_TESTING=OFF", "-DCMAKE_MODULE_PATH=" .. cmakedir}
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
