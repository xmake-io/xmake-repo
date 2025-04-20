package("streamvbyte")
    set_homepage("https://github.com/lemire/streamvbyte")
    set_description("Fast integer compression in C using the StreamVByte codec")
    set_license("Apache-2.0")

    add_urls("https://github.com/lemire/streamvbyte/archive/refs/tags/$(version).tar.gz",
             "https://github.com/lemire/streamvbyte.git")

    add_versions("v2.0.0", "51ca1c3b02648ea4b965d65b0e586891981f2e8184b056520e38ad70bcc43dd8")
    add_versions("v1.0.0", "6b1920e9865146ba444cc317aa61cd39cdf760236e354ef7956011a9fe577882")

    add_deps("cmake")

    if on_check then
        on_check("windows", function (target)
            if package:version() and package:version():eq("2.0.0") then
                if package:is_arch("arm.*") then
                    raise("package(streamvbyte 2.0.0) unsupported arm arch")
                end
            end
        end)
    end

    on_install(function (package)
        io.replace("CMakeLists.txt", "set(CMAKE_POSITION_INDEPENDENT_CODE ON)", "", {plain = true})

        local configs = {"-DSTREAMVBYTE_ENABLE_EXAMPLES=OFF", "-DSTREAMVBYTE_ENABLE_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSTREAMVBYTE_SANITIZE=" .. (package:config("asan") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("streamvbyte_encode", {includes = "streamvbyte.h"}))
    end)
