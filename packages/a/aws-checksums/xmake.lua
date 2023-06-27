package("aws-checksums")
    set_homepage("https://github.com/awslabs/aws-checksums")
    set_description("Cross platform HW accelerated CRC32c and CRC32 with fallback to efficient SW implementations - C interface with language bindings for AWS SDKs")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-checksums/archive/$(version).tar.gz",
             "https://github.com/awslabs/aws-checksums.git")
    add_versions("v0.1.12", "394723034b81cc7cd528401775bc7aca2b12c7471c92350c80a0e2fb9d2909fe")

    if is_plat("linux") then
        add_deps("cmake")
    end

    on_load(function (package)
        if package:config("shared") then
            package:add("deps", "aws-c-common", {configs = {shared = true}})
        else
            package:add("deps", "aws-c-common")
        end
    end)

    on_install("linux", function (package)
        local configs = {}
        local common_cmake_dir = package:dep("aws-c-common"):installdir("lib", "cmake")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "list(APPEND CMAKE_MODULE_PATH ${AWS_MODULE_PATH})",
            "list(APPEND CMAKE_MODULE_PATH \"" .. common_cmake_dir .. "\")", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aws_checksums_crc32", {includes = "aws/checksums/crc.h"}))
    end)
