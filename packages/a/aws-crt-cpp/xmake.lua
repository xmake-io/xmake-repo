package("aws-crt-cpp")
    set_homepage("https://github.com/awslabs/aws-crt-cpp")
    set_description("C++ wrapper around the aws-c-* libraries. Provides Cross-Platform Transport Protocols and SSL/TLS implementations for C++.")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-crt-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-crt-cpp.git")

    add_versions("v0.37.1", "b91b70c436bd2d35a8758871983312bea63696ff34ef8e44ec1b86072db28a18")
    add_versions("v0.29.8", "a693b1b6a802dd8bf0210cbb9f01fd58a95c851309a10a221e1ba7496b81384c")
    add_versions("v0.29.5", "17dd4a39537b5bd4040ff951c5a658e27c5d74d3f3cfab72831d3ecbabd58d35")
    add_versions("v0.28.3", "0d0255eb1983ff3b6f7a7e98a54f65e2e8b40a7c7d6118a96a9c656ada7afb5f")
    add_versions("v0.28.2", "7f27df9d2028008e665bab4b2e094365eac696610610e52182c679a43dbeaf6f")
    add_versions("v0.27.5", "cc69252ee132f5cc76b1fcf1ebec574e88f7080b05caa8125aab5684b26a37b9")
    add_versions("v0.27.4", "0554776a4cbbea016075f4a28698ff22818c5b948296171e1f76d0a787576f83")
    add_versions("v0.27.2", "e17c82d7cc3b5e6e4300bc7e4794306e292b5281d212ead536000a8b5f5f1be4")
    add_versions("v0.27.0", "e7601c8c5e6391013b6ad164d2dd7b970bf5dbb3693b9cc80c424bd6f42b79c8")
    add_versions("v0.26.11", "23acb2b14019182dd73fe6779ec266ee4d8937f19a99803da6407937fa22db7d")
    add_versions("v0.26.9", "5b5760d34fbbfcc971f561296e828de4c788750472fd9bd3ac20068a083620f2")
    add_versions("v0.26.8", "36ced4fb54c8eb7325b4576134e01f93bfaca2709565b5ad036d198d703e4c8f")
    add_versions("v0.26.4", "486113a556614b7b824e1aefec365a2261154fe06321b85601aefe2f65bd0706")
    add_versions("v0.23.1", "8f7029fea12907564b80260cbea4a2b268ca678e7427def3e0c46871e9b42d16")

    add_configs("openssl", {description = "Set this if you want to use your system's OpenSSL 1.0.2/1.1.1 compatible libcrypto", default = false, type = "boolean"})

    add_deps("cmake", "aws-c-common", "aws-c-io", "aws-checksums", "aws-c-event-stream",
             "aws-c-http", "aws-c-mqtt", "aws-c-auth", "aws-c-s3")

    on_install("windows|x64", "windows|x86", "linux", "macosx", "bsd", "msys", function (package)
        local cmakedir = package:dep("aws-c-common"):installdir("lib", "cmake")
        if package:is_plat("windows") then
            cmakedir = cmakedir:gsub("\\", "/")
        end

        local configs = {"-DBUILD_TESTING=OFF", "-DCMAKE_MODULE_PATH=" .. cmakedir, "-DBUILD_DEPS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SANITIZERS=" .. (package:config("asan") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DAWS_STATIC_MSVC_RUNTIME_LIBRARY=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))

            if package:version():lt("0.31.2") then
                io.replace("include/aws/crt/Exports.h", "defined(WIN32)", "defined(_WIN32)", {plain = true})
            end
            if package:config("shared") then
                package:add("defines", "AWS_CRT_CPP_USE_IMPORT_EXPORT")
            end
        end
        table.insert(configs, "-DUSE_OPENSSL=" .. (package:config("openssl") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <aws/crt/Api.h>
            void test() {
                Aws::Crt::ApiHandle apiHandle;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
