package("google-cloud-cpp")
    set_homepage("https://github.com/googleapis/google-cloud-cpp")
    set_description("C++ Client Libraries for Google Cloud Services")
    set_license("Apache-2.0")

    add_urls("https://github.com/googleapis/google-cloud-cpp/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/googleapis/google-cloud-cpp.git")
    add_versions("2.32.0","db69dd73ef4af8b2e816d80ded04950036d0e0dccc274f8c3d3ed1d7f5692a1b")

    add_deps("cmake")
    add_deps("abseil", "crc32c", "libcurl", "openssl3", "zlib")
    add_deps("nlohmann_json", {configs = {cmake = true}})

    on_check(function (package)
        if package:is_plat("android") then
            raise("package(google-cloud-cpp) unsupported on android due to package(grpc) is unsupported on android yet.")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DGOOGLE_CLOUD_CPP_WITH_MOCKS=OFF",
            "-DGOOGLE_CLOUD_CPP_ENABLE_MACOS_OPENSSL_CHECK=OFF",
            "-DGOOGLE_CLOUD_CPP_ENABLE_WERROR=OFF",
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_load(function (package)
        if package:config("shared") then
            package:add("deps","protobuf-cpp",{shared= true})
            package:add("deps","grpc",{shared= true})
        else
            package:add("deps","protobuf-cpp")
            package:add("deps","grpc")
        end
            
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "google/cloud/version.h"
            int test() {
              google::cloud::version_string();
              return 0;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)


