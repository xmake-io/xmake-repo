package("aws-c-http")
    set_homepage("https://github.com/awslabs/aws-c-http")
    set_description("C99 implementation of the HTTP/1.1 and HTTP/2 specifications")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-http/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-http.git")

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
