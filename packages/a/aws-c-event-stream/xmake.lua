package("aws-c-event-stream")
    set_homepage("https://github.com/awslabs/aws-c-event-stream")
    set_description("C99 implementation of the vnd.amazon.eventstream content-type.")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-event-stream/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-event-stream.git")

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
