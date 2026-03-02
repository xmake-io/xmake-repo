package("aws-sdk-cpp")
    set_homepage("https://github.com/aws/aws-sdk-cpp")
    set_description("AWS SDK for C++")
    set_license("Apache-2.0")

    add_urls("https://github.com/aws/aws-sdk-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/aws/aws-sdk-cpp.git")
    add_versions("1.11.760", "3ac64ead91530bada83b5eaffbccecd77de55151d3e7754889a1ec60e437f31e")

    add_configs("build_only",  {description = 'By default, all SDKS are built, if only AWS S3 is required, then set build_only="s3", with multiple SDKS separated by commas.'})
    add_configs("http_client", {description = 'If disabled, no platform-default http client will be included in the library.', default = true, type = "boolean"})
    add_configs("encryption",  {description = 'If disabled, no platform-default encryption will be included in the library.', default = true, type = "boolean", readonly = true}) -- since 1.9 this must be true

    add_deps("zlib")
    add_deps("cmake")
    add_deps("aws-checksums")
    add_deps("aws-crt-cpp")
    add_deps("aws-c-http")
    add_deps("aws-c-mqtt")
    add_deps("aws-c-cal")
    add_deps("aws-c-auth")
    add_deps("aws-c-common")
    add_deps("aws-c-io")
    add_deps("aws-c-event-stream")
    add_deps("aws-c-s3")
    add_deps("aws-c-compression")
    add_deps("aws-c-sdkutils")

    on_load(function (package)
        if package:config("http_client") then
            package:add("deps", "libcurl", {configs = {openssl = true, zlib = true}})
            if package:is_plat("macosx") then
                package:add("frameworks", "Foundation", "CoreFoundation", "Security", "SystemConfiguration")
            end
        end
        if package:config("encryption") then
            package:add("deps", "openssl")
        end
    end)

    on_install("linux", "macosx|arm64", function (package)
        local configs = {"-DBUILD_DEPS=OFF", "-DENABLE_TESTING=OFF", "-DAUTORUN_UNIT_TESTS=OFF", "-DAWS_SDK_WARNINGS_ARE_ERRORS=OFF"}
        table.insert(configs, "-DMINIMIZE_SIZE=ON")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DNO_HTTP_CLIENT=" .. (package:config("http_client") and "OFF" or "ON"))
        table.insert(configs, "-DNO_ENCRYPTION=" .. (package:config("encryption") and "OFF" or "ON"))
        table.insert(configs, "-DUSE_OPENSSL=" .. (package:config("encryption") and "ON" or "OFF"))
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
