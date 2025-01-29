package("aws-c-sdkutils")
    set_homepage("https://github.com/awslabs/aws-c-sdkutils")
    set_description("C99 library implementing AWS SDK specific utilities. Includes utilities for ARN parsing, reading AWS profiles, etc...")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-sdkutils/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-sdkutils.git")

    add_versions("v0.2.3", "5a0489d508341b84eea556e351717bc33524d3dfd6207ee3aba6068994ea6018")
    add_versions("v0.2.2", "75defbfd4d896b8bdc0790bd25d854218acae61b9409d1956d33832924b82045")
    add_versions("v0.2.1", "17bdec593f3ae8a837622ef81055db81cc2dd14b86d33b21df878a7ab918d0e4")
    add_versions("v0.2.0", "5c73caa1c0ebde71b357d05a8f0ff6c1be09b32e0935b16d7385c9342f3e59c2")
    add_versions("v0.1.19", "66bd7a8679703386aec1539407aaed0942a78032fe340ab44e810a3cf6d7e505")
    add_versions("v0.1.16", "4a818563d7c6636b5b245f5d22d4d7c804fa33fc4ea6976e9c296d272f4966d3")
    add_versions("v0.1.15", "15fa30b8b0a357128388f2f40ab0ba3df63742fd333cc2f89cb91a9169f03bdc")
    add_versions("v0.1.12", "c876c3ce2918f1181c24829f599c8f06e29733f0bd6556d4c4fb523390561316")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake", "aws-c-common")

    on_install("!mingw or mingw|!i386", function (package)
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
