package("aws-sdk-cpp")
    set_homepage("https://github.com/aws/aws-sdk-cpp")
    set_description("AWS SDK for C++")

    add_urls("https://github.com/aws/aws-sdk-cpp.git")
    add_versions("1.9.362", "e9372218a2c8fab756ecaa6e4fefcdb33c3670c1")

    add_configs("build_only", {description = 'By default, all SDKS are built, if only AWS S3 is required, then set build_only="s3", with multiple SDKS separated by commas.'})
    add_deps("libcurl", "openssl", "zlib")
    add_deps("cmake")

    on_install("linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "-DMINIMIZE_SIZE=ON")
        table.insert(configs, "-DCMAKE_PREFIX_PATH=" .. package:installdir())
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_TESTING=" .. (package:config("enable_testing") and "ON" or "OFF"))
        table.insert(configs, "-DAUTORUN_UNIT_TESTS=" .. (package:config("autorun_unit_tests") and "ON" or "OFF"))
        if package:config("build_only") then
            table.insert(configs, "-DBUILD_ONLY=" .. package:config("build_only"))
        end
        import("package.tools.cmake").install(package, configs)
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
