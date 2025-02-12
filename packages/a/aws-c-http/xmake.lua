package("aws-c-http")
    set_homepage("https://github.com/awslabs/aws-c-http")
    set_description("C99 implementation of the HTTP/1.1 and HTTP/2 specifications")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-http/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-http.git")

    add_versions("v0.9.3", "63061321fd3234a4f8688cff1a6681089321519436a5f181e1bcb359204df7c8")
    add_versions("v0.9.2", "328013ebc2b5725326cac01941041eec1e1010058c60709da2c23aa8fb967370")
    add_versions("v0.9.0", "ffba3a208e605ed247a130e2986f9d524283faf85f26da3452aac878ecefdfa2")
    add_versions("v0.8.10", "f878802a4e0bcefadce9959ce443acaf77607a68d138f9d3db04a5a878f1a871")
    add_versions("v0.8.7", "173ed7634c87485c2defbd9a96a246a79ec3f3659b28b235ac38e6e92d67392a")
    add_versions("v0.8.2", "a76ba75e59e1ac169df3ec00c0d1c453db1a4db85ee8acd3282a85ee63d6b31c")
    add_versions("v0.8.1", "83fb47e2d7956469bb328f16dea96663e96f8f20dc60dc4e9676b82804588530")
    add_versions("v0.7.12", "0f92f295c96e10aa9c1e66ac73c038ee9d9c61e1be7551e721ee0dab9c89fc6f")

    add_configs("asan", {description = "Enable Address Sanitize.", default = false, type = "boolean"})

    add_deps("cmake", "aws-c-cal", "aws-c-io", "aws-c-compression")

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
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aws_http_message_new_request", {includes = "aws/http/request_response.h"}))
    end)
