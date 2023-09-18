package("aws-c-io")
    set_homepage("https://github.com/awslabs/aws-c-io")
    set_description("This is a module for the AWS SDK for C. It handles all IO and TLS work for application protocols. ")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-io/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-io.git")

    add_versions("v0.13.32", "2a6b18c544d014ca4f55cb96002dbbc1e52a2120541c809fa974cb0838ea72cc")

    add_configs("asan", {description = "Enable Address Sanitize.", default = false, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("advapi32", "crypt32", "secur32", "ncrypt")
    elseif is_plat("linux") then
        add_deps("s2n-tls")
    end

    add_deps("cmake", "aws-c-common", "aws-c-cal")

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
        assert(package:has_cfuncs("aws_io_library_init", {includes = "aws/io/io.h"}))
    end)
