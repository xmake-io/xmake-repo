package("aws-checksums")
    set_homepage("https://github.com/awslabs/aws-checksums")
    set_description("Cross platform HW accelerated CRC32c and CRC32 with fallback to efficient SW implementations - C interface with language bindings for AWS SDKs")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-checksums/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-checksums.git")

    add_versions("v0.1.17", "83c1fbae826631361a529e9565e64a942c412baaec6b705ae5da3f056b97b958")

    add_configs("asan", {description = "Enable Address Sanitize.", default = false, type = "boolean"})

    add_deps("cmake", "aws-c-common")

    on_install("windows|x64", "windows|x86", "linux", "macosx", "bsd", "msys", "cross", function (package)
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
        assert(package:has_cfuncs("aws_checksums_crc32", {includes = "aws/checksums/crc.h"}))
    end)
