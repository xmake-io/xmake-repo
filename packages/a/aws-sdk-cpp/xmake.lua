package("aws-sdk-cpp")
    set_homepage("https://github.com/aws/aws-sdk-cpp")
    set_description("AWS SDK for C++")

    add_urls("https://github.com/aws/aws-sdk-cpp.git")
    add_versions("1.9.362", "e9372218a2c8fab756ecaa6e4fefcdb33c3670c1")
    add_versions("1.11.521", "9f6bfafbb9a82efe1c18e7d457fc97b848de3ee6")

    add_configs("build_only",  {description = 'By default, all SDKS are built, if only AWS S3 is required, then set build_only="s3", with multiple SDKS separated by commas.'})
    add_configs("http_client", {description = 'If disabled, no platform-default http client will be included in the library.', default = true, type = "boolean"})
    add_configs("encryption",  {description = 'If disabled, no platform-default encryption will be included in the library.', default = false, type = "boolean"})

    add_deps("zlib")
    add_deps("cmake")

    on_load(function (package)
        if package:config("http_client") then
            package:add("deps", "libcurl")
            if package:is_plat("macosx") then
                package:add("frameworks", "Foundation", "CoreFoundation", "Security", "SystemConfiguration")
            end
        end
        if package:config("encryption") then
            package:add("deps", "openssl")
        end
    end)

    on_install("linux", "macosx", function (package)
        io.replace("cmake/Findcrypto.cmake",
            "if (BUILD_SHARED_LIBS)\n            set(crypto_LIBRARY ${crypto_SHARED_LIBRARY})",
            [[
                if (BUILD_SHARED_LIBS)
                    if (crypto_SHARED_LIBRARY)
                        set(crypto_LIBRARY ${crypto_SHARED_LIBRARY})
                    else()
                        set(crypto_LIBRARY ${crypto_STATIC_LIBRARY})
                    endif()
            ]], {plain = true})
        local configs = {"-DENABLE_TESTING=OFF", "-DAUTORUN_UNIT_TESTS=OFF"}
        table.insert(configs, "-DMINIMIZE_SIZE=ON")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DNO_HTTP_CLIENT=" .. (package:config("http_client") and "OFF" or "ON"))
        table.insert(configs, "-DNO_ENCRYPTION=" .. (package:config("encryption") and "OFF" or "ON"))
        if package:config("build_only") then
            table.insert(configs, "-DBUILD_ONLY=" .. package:config("build_only"))
        end
        if package:config("http_client") and package:is_plat("macosx") then
            local exflags = {"-framework", "CoreFoundation", "-framework", "Security", "-framework", "SystemConfiguration"}
            import("package.tools.cmake").install(package, configs, {shflags = exflags, ldflags = exflags})
        else
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({
            test = [[
              #include <aws/core/Aws.h>
              static void test() {
                Aws::SDKOptions options;
              }
            ]]
        }, {configs = {languages = "c++11"}}))
    end)
