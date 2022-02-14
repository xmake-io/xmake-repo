package("hiredis")

    set_homepage("https://github.com/redis/hiredis")
    set_description("Minimalistic C client for Redis >= 1.2")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/redis/hiredis/archive/refs/tags/$(version).tar.gz",
             "https://github.com/redis/hiredis.git")
    add_versions('v1.0.2', 'e0ab696e2f07deb4252dda45b703d09854e53b9703c7d52182ce5a22616c3819')

    add_configs("openssl", {description = "with openssl library", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("openssl") then
            package:add("deps", "openssl")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DDISABLE_TESTS=ON",
            "-DENABLE_SSL_TESTS=OFF",
            "-DENABLE_ASYNC_TESTS=OFF",
        }

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DENABLE_SSL=" .. (package:config("openssl") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("redisCommand", {includes = "hiredis/hiredis.h"}))
    end)
