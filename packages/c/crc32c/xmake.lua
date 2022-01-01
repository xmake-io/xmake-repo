package("crc32c")

    set_homepage("https://github.com/google/crc32c")
    set_description("CRC32C implementation with support for CPU-specific acceleration instructions")

    add_urls("https://github.com/google/crc32c/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/crc32c.git")

    add_versions("1.1.2", "ac07840513072b7fcebda6e821068aa04889018f24e10e46181068fb214d7e56")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake")
        local configs = {"-DCRC32C_BUILD_TESTS=OFF", "-DCRC32C_BUILD_BENCHMARKS=OFF", "-DCRC32C_USE_GLOG=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=on")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=off")
        end
        cmake.install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("crc32c_value", {includes = "crc32c/crc32c.h"}))
    end)
