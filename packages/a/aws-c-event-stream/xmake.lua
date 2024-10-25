package("aws-c-event-stream")
    set_homepage("https://github.com/awslabs/aws-c-event-stream")
    set_description("C99 implementation of the vnd.amazon.eventstream content-type.")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-event-stream/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-event-stream.git")

    add_versions("v0.5.0", "3a53a9d05f9e2fd06036a12854a8b4f05a0c4858bb5b8df8a30edba9de8532b5")
    add_versions("v0.4.3", "d7d82c38bae68d2287ac59972a76b2b6159e7a3d7c9b7edb1357495aa4d0c0de")
    add_versions("v0.4.2", "c98b8fa05c2ca10aacfce7327b92a84669c2da95ccb8e7d7b3e3285fcec8beee")
    add_versions("v0.4.1", "f8915fba57c86148f8df4c303ca6f31de6c23375de554ba8d6f9aef2a980e93e")
    add_versions("v0.3.2", "3134b35a45e9f9d974c2b78ee44fd2ea0aebc04df80236b80692aa63bee2092e")

    add_configs("asan", {description = "Enable Address Sanitize.", default = false, type = "boolean"})

    add_deps("cmake", "aws-c-common", "aws-c-io", "aws-checksums")

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
        assert(package:has_cfuncs("aws_event_stream_library_init", {includes = "aws/event-stream/event_stream.h"}))
    end)
