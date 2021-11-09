package("libevent")

    set_homepage("https://libevent.org/")
    set_description("libevent – an event notification library")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/libevent/libevent/releases/download/release-$(version)-stable/libevent-$(version)-stable.tar.gz")
    add_urls("https://github.com/libevent/libevent.git")
    add_versions("2.1.12", "92e6de1be9ec176428fd2367677e61ceffc2ee1cb119035037a27d346b0403bb")

    add_configs("openssl", {description = "Build with OpenSSL library.", default = false, type = "boolean"})
    add_configs("mbedtls", {description = "Build with mbedtls library.", default = false, type = "boolean"})

    add_deps("cmake")
    on_load(function (package)
        if package:config("openssl") then
            package:add("deps", "openssl")
        end
        if package:config("mbedtls") then
            package:add("deps", "mbedtls")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        io.replace("CMakeLists.txt", "advapi32", "advapi32 crypt32", {plain = true})
        local configs = {"-DEVENT__DISABLE_TESTS=ON", "-DEVENT__DISABLE_REGRESS=ON", "-DEVENT__DISABLE_SAMPLES=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DEVENT__DISABLE_OPENSSL=" .. (package:config("openssl") and "OFF" or "ON"))
        table.insert(configs, "-DEVENT__DISABLE_MBEDTLS=" .. (package:config("mbedtls") and "OFF" or "ON"))
        if package:is_plat("windows") then
            table.insert(configs, "-DEVENT__MSVC_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("event_base_new", {includes = "event2/event.h"}))
    end)
