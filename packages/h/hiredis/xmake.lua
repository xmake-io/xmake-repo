package("hiredis")

    set_homepage("https://github.com/redis/hiredis")
    set_description("Minimalistic C client for Redis >= 1.2")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/redis/hiredis/archive/refs/tags/$(version).tar.gz",
             "https://github.com/redis/hiredis.git")
    add_versions('v1.0.2', 'e0ab696e2f07deb4252dda45b703d09854e53b9703c7d52182ce5a22616c3819')
    -- This patch is created with hiredis commit f8de9a4. Removed NuGet related install code.
    -- We need latest CMakeLists.txt to get static library support. It also contains other fixes.
    add_patches("v1.0.2", path.join(os.scriptdir(), "patches", "v1.0.2", "cmake.patch"), "a2115f727821e4a121e4e2145ef3e5caa0669559f24f2213125119520ee4d881")

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

        -- hiredis cmake builds static and shared library at the same time.
        -- Remove unneeded one after install.
        if package:config("shared") then 
            os.tryrm(path.join(package:installdir("lib"), "*.a")) 
        else 
            os.tryrm(path.join(package:installdir("lib"), "*.so")) 
            os.tryrm(path.join(package:installdir("lib"), "*.so.*")) 
            os.tryrm(path.join(package:installdir("lib"), "*.dylib")) 
        end 
    end)

    on_test(function (package)
        assert(package:has_cfuncs("redisCommand", {includes = "hiredis/hiredis.h"}))
    end)
