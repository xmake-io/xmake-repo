package("aws-c-sdkutils")
    set_homepage("https://github.com/awslabs/aws-c-sdkutils")
    set_description("C99 library implementing AWS SDK specific utilities. Includes utilities for ARN parsing, reading AWS profiles, etc...")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-sdkutils/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-sdkutils.git")

    add_versions("v0.1.16", "4a818563d7c6636b5b245f5d22d4d7c804fa33fc4ea6976e9c296d272f4966d3")
    add_versions("v0.1.15", "15fa30b8b0a357128388f2f40ab0ba3df63742fd333cc2f89cb91a9169f03bdc")
    add_versions("v0.1.12", "c876c3ce2918f1181c24829f599c8f06e29733f0bd6556d4c4fb523390561316")

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
        assert(package:has_cfuncs("aws_sdkutils_library_init", {includes = "aws/sdkutils/sdkutils.h"}))
    end)
