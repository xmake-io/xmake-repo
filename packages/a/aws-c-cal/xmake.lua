package("aws-c-cal")
    set_homepage("https://github.com/awslabs/aws-c-cal")
    set_description("Aws Crypto Abstraction Layer: Cross-Platform, C99 wrapper for cryptography primitives.")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-cal/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-cal.git")

    add_versions("v0.9.13", "80b7c6087b0af461b4483e4c9483aea2e0dac5d9fb2289b057159ea6032409e1")
    add_versions("v0.9.11", "319720ca46f2d23c3b5e44f4b48a1d468c49983bd0970d09cf0ddee4f4450d39")
    add_versions("v0.9.10", "a41b389e942fadd599a6a0f692b75480d663f1e702c0301177f00f365e0c9b94")
    add_versions("v0.9.5", "5cedd82d093960a09a91bf8d8c3540425e49972ed9b565763bf2a5b2ba1a2a7c")
    add_versions("v0.9.2", "f9f3bc6a069e2efe25fcdf73e4d2b16b5608c327d2eb57c8f7a8524e9e1fcad0")
    add_versions("v0.9.0", "516ff370a45bfc49fd6d34a9bd2b1b3e753221046a9e2fbd117341d6f9d39edc")
    add_versions("v0.8.7", "5882096093f6f39d9442f9b8a4e377155a6846277d4277334a58cd36b736674f")
    add_versions("v0.8.3", "413a5226a881eb2d7c7b453707c90b6ad1c0f63edfc15e87087f56d7d10c2a1b")
    add_versions("v0.8.1", "4d603641758ef350c3e5401184804e8a6bba4aa5294593cc6228b0dca77b22f5")
    add_versions("v0.8.0", "3803311ee7c73446a35466199084652ec5f76dedcf20452ebdbba8ed34d4230d")
    add_versions("v0.7.4", "8020ecbe850ceb402aa9c81a1ef34e3becdbcb49587a1b19eb5c7e040f369b58")
    add_versions("v0.7.2", "265938e3f1d2baa6a555ec6b0a27c74d3f505cbe7c96f7539ada42d5a848dee9")
    add_versions("v0.7.1", "2fbdc04d72d1f3af28b80fe3917f03f20c0a62bc22b6c7b3450486ee9cbe77f6")
    add_versions("v0.6.15", "67dda8049a59bbb70cdb166f46f741bc3a8443c86009a1ae4cb7842964a76e0d")
    add_versions("v0.6.14", "2326304b15bec45b212f6b738020c21afa41f9da295936687e103f9f2efb7b5e")
    add_versions("v0.6.12", "1ec1bc9a50df8d620f226480b420ec69d4fefd3792fb4e877aa7e350c2b174dc")
    add_versions("v0.6.11", "e1b0af88c14300e125e86ee010d4c731292851fff16cfb67eb6ba6036df2d648")
    add_versions("v0.6.2", "777feb1e88b261415e1ad607f7e420a743c3b432e21a66a5aaf9249149dc6fef")

    add_configs("openssl", {description = "Set this if you want to use your system's OpenSSL 1.0.2/1.1.1 compatible libcrypto", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("windows","mingw") then
        add_syslinks("bcrypt", "ncrypt")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("macosx", "iphoneos") then
        add_frameworks("Security", "CoreFoundation")
    end

    add_deps("cmake", "aws-c-common")

    on_load(function (package)
        if package:is_plat("linux", "bsd", "cross", "android") then
            package:config_set("openssl", true)
        end
        if package:config("openssl") then
            package:add("deps", "openssl")
        end
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "AWS_C_RT_USE_WINDOWS_DLL_SEMANTICS", "AWS_CAL_USE_IMPORT_EXPORT")
        end
    end)

    on_install("!wasm and (!mingw or mingw|!i386)", function (package)
        local cmakedir = path.unix(package:dep("aws-c-common"):installdir("lib", "cmake"))

        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
            "-DCMAKE_MODULE_PATH=" .. cmakedir,
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SANITIZERS=" .. (package:config("asan") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DAWS_STATIC_MSVC_RUNTIME_LIBRARY=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        table.insert(configs, "-DUSE_OPENSSL=" .. (package:config("openssl") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "*.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aws_sha256_new", {includes = "aws/cal/hash.h"}))
    end)
