package("aws-c-http")
    set_homepage("https://github.com/awslabs/aws-c-http")
    set_description("C99 implementation of the HTTP/1.1 and HTTP/2 specifications")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-http/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-http.git")

    add_versions("v0.10.9", "472653537a6c2e9dbf44a4e14991f65e61e65d43c120efe2c5f06b7f57363a2c")
    add_versions("v0.10.7", "ce9e71c3eae67b1c6c0149278e0d0929a7d928c3547de64999430c8592864ad4")
    add_versions("v0.10.6", "0e513d25bc49a7f583d9bb246dabbe64d23d8a2bd105026a8f914d05aa1df147")
    add_versions("v0.10.1", "1550f7bf9666bb8f86514db9e623f07249e3c53e868d2f36ff69b83bd3eadfec")
    add_versions("v0.10.0", "f7881e2f9af1a2e114b4147be80d70480f06af2b9cd195e8448afb750c74b1ae")
    add_versions("v0.9.5", "cbdb8411b439677f302d3a3b4691e2dc1852e69f406d3c2fced2be95ae2397f9")
    add_versions("v0.9.4", "2282067c4eb0bd07f632facb52c98bb6380f74410bc8640256e9490b66a2d582")
    add_versions("v0.9.3", "63061321fd3234a4f8688cff1a6681089321519436a5f181e1bcb359204df7c8")
    add_versions("v0.9.2", "328013ebc2b5725326cac01941041eec1e1010058c60709da2c23aa8fb967370")
    add_versions("v0.9.0", "ffba3a208e605ed247a130e2986f9d524283faf85f26da3452aac878ecefdfa2")
    add_versions("v0.8.10", "f878802a4e0bcefadce9959ce443acaf77607a68d138f9d3db04a5a878f1a871")
    add_versions("v0.8.7", "173ed7634c87485c2defbd9a96a246a79ec3f3659b28b235ac38e6e92d67392a")
    add_versions("v0.8.2", "a76ba75e59e1ac169df3ec00c0d1c453db1a4db85ee8acd3282a85ee63d6b31c")
    add_versions("v0.8.1", "83fb47e2d7956469bb328f16dea96663e96f8f20dc60dc4e9676b82804588530")
    add_versions("v0.7.12", "0f92f295c96e10aa9c1e66ac73c038ee9d9c61e1be7551e721ee0dab9c89fc6f")

    add_deps("cmake")
    add_deps("aws-c-compression")

    on_load(function (package)
        if package:version():le("0.10.7") then
            package:add("deps", "aws-c-io <=0.23")
        else
            package:add("deps", "aws-c-io")
        end
    end)

    on_install("!wasm and (!mingw or mingw|!i386)", function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "USE_WINDOWS_DLL_SEMANTICS", "AWS_HTTP_USE_IMPORT_EXPORT")
        end

        local cmakedir = package:dep("aws-c-common"):installdir("lib/cmake")
        if is_host("windows") then
            cmakedir = cmakedir:gsub("\\", "/")
        end

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
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aws_http_message_new_request", {includes = "aws/http/request_response.h"}))
    end)
