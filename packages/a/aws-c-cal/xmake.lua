package("aws-c-cal")
    set_homepage("https://github.com/awslabs/aws-c-cal")
    set_description("Aws Crypto Abstraction Layer: Cross-Platform, C99 wrapper for cryptography primitives.")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-cal/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-cal.git")

    add_versions("v0.6.14", "2326304b15bec45b212f6b738020c21afa41f9da295936687e103f9f2efb7b5e")
    add_versions("v0.6.12", "1ec1bc9a50df8d620f226480b420ec69d4fefd3792fb4e877aa7e350c2b174dc")
    add_versions("v0.6.11", "e1b0af88c14300e125e86ee010d4c731292851fff16cfb67eb6ba6036df2d648")
    add_versions("v0.6.2", "777feb1e88b261415e1ad607f7e420a743c3b432e21a66a5aaf9249149dc6fef")

    add_configs("openssl", {description = "Set this if you want to use your system's OpenSSL 1.0.2/1.1.1 compatible libcrypto", default = false, type = "boolean"})
    add_configs("asan", {description = "Enable Address Sanitize.", default = false, type = "boolean"})

    add_deps("cmake", "aws-c-common")

    on_load(function (package)
        if not package:is_plat("windows", "mingw", "msys", "macosx") then
            package:config_set("openssl", true)
        end
        if package:config("openssl") then
            package:add("deps", "openssl")
        end
    end)

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
        table.insert(configs, "-DUSE_OPENSSL=" .. (package:config("openssl") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aws_sha256_new", {includes = "aws/cal/hash.h"}))
    end)
