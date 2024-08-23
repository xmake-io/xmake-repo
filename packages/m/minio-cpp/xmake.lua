package("minio-cpp")
    set_homepage("https://minio-cpp.min.io/")
    set_description("MinIO C++ Client SDK for Amazon S3 Compatible Cloud Storage")
    set_license("Apache-2.0")

    add_urls("https://github.com/minio/minio-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/minio/minio-cpp.git")

    add_versions("v0.3.0", "da0f2f54bf169ad9e5e9368cc9143df4db056fc5c05bb55d8c1d9065e7211f7c")

    add_patches("0.3.0", "patches/0.3.0/cmake-remove-unofficial.patch", "974d2369b994b1a12d0596dccf2ef02be86b3a26528f75812a827639edd85367")

    add_deps("cmake", "pkgconf")
    add_deps("nlohmann_json", {configs = {cmake = true}})
    add_deps("inih", {configs = {ini_parser = true}})
    add_deps("openssl", "curlpp", "pugixml", "zlib")

    on_install("windows", "linux", "macosx", "mingw", "cross", function (package)
        io.replace("src/utils.cc", "#include <openssl/types.h>", "", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = {"curlpp", "libcurl", "inih"}})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                minio::s3::BaseUrl base_url("play.min.io");
                minio::creds::StaticProvider provider("Q3AM3UQ867SPQQA43P2F", "zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG");
                minio::s3::Client client(base_url, &provider);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "miniocpp/client.h"}))
    end)
