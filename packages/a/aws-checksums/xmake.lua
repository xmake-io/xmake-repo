package("aws-checksums")
    set_homepage("https://github.com/awslabs/aws-checksums")
    set_description("Cross platform HW accelerated CRC32c and CRC32 with fallback to efficient SW implementations - C interface with language bindings for AWS SDKs")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-checksums/archive/$(version).tar.gz")
    add_versions("v0.1.12", "394723034b81cc7cd528401775bc7aca2b12c7471c92350c80a0e2fb9d2909fe")

    if is_plat("linux") then
      add_deps("cmake", "aws-c-common")
    end

    on_install("linux", function (package)
        local configs = {}

        local common_cmake_files = package:dep("aws-c-common"):installdir("lib", "cmake")
        if os.isdir(common_cmake_files) then
            os.cp(common_cmake_files .. "/*.cmake", package:installdir("lib", "cmake"))
        end

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aws_checksums_crc32", {includes = "aws/checksums/crc.h"}))
    end)
