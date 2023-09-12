package("aws-c-common")
    set_homepage("https://github.com/awslabs/aws-c-common")
    set_description("Core c99 package for AWS SDK for C")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-common/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-common.git")

    add_versions("v0.9.3", "389eaac7f64d7d5a91ca3decad6810429eb5a65bbba54798b9beffcb4d1d1ed6")

    add_configs("asan", {description = "Enable Address Sanitize.", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("windows", "mingw") then
        add_syslinks("bcrypt", "ws2_32", "shlwapi")
    elseif is_plat("linux", "bsd") then
        add_syslinks("dl", "m", "pthread", "rt")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation")
    end

    add_deps("cmake")

    on_install("windows|x64", "windows|x86", "linux", "macosx", "bsd", "mingw", "msys", "android", "iphoneos", "cross", "wasm", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SANITIZERS=" .. (package:config("asan") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DAWS_STATIC_MSVC_RUNTIME_LIBRARY=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aws_common_library_init", {includes = "aws/common/common.h"}))
        assert(package:has_cfuncs("aws_common_library_clean_up", {includes = "aws/common/common.h"}))
        assert(package:has_cfuncs("aws_ring_buffer_init", {includes = "aws/common/ring_buffer.h"}))
        assert(package:has_cfuncs("aws_uuid_init", {includes = "aws/common/uuid.h"}))
    end)
