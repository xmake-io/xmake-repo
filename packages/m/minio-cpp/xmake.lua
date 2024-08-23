package("minio-cpp")
    set_homepage("https://minio-cpp.min.io/")
    set_description("MinIO C++ Client SDK for Amazon S3 Compatible Cloud Storage")
    set_license("Apache-2.0")

    add_urls("https://github.com/minio/minio-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/minio/minio-cpp.git")

    add_versions("v0.3.0", "da0f2f54bf169ad9e5e9368cc9143df4db056fc5c05bb55d8c1d9065e7211f7c")

    add_patches("0.3.0", "patches/0.3.0/cmake-pkgconfig-find-deps.patch", "53a0a5a300c896ad92dbaf3b96fa25556a2f555e84ce07deb7b7b1562ddac9e5")

    add_deps("cmake", "pkgconf")
    add_deps("nlohmann_json", {configs = {cmake = true}})
    add_deps("inih", {configs = {ini_parser = true}})
    add_deps("openssl", "curlpp", "pugixml", "zlib")

    on_install("windows", "linux", "macosx", "mingw", function (package)
        io.replace("src/utils.cc", "#include <openssl/types.h>", "", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        local envs = import("package.tools.cmake").buildenvs(package)
        if is_subhost("msys") then
            -- xmake bug, Fixed after v2.9.5
            envs.PKG_CONFIG_PATH = table.concat(envs.PKG_CONFIG_PATH:split(";"), ":")
        end
        import("package.tools.cmake").install(package, configs, {envs = envs})
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
