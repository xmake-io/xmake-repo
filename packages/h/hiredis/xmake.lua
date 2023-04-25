package("hiredis")

    set_homepage("https://github.com/redis/hiredis")
    set_description("Minimalistic C client for Redis >= 1.2")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/redis/hiredis/archive/refs/tags/$(version).tar.gz",
             "https://github.com/redis/hiredis.git")
    add_versions('v1.0.2', 'e0ab696e2f07deb4252dda45b703d09854e53b9703c7d52182ce5a22616c3819')
    add_versions('v1.1.0', 'fe6d21741ec7f3fc9df409d921f47dfc73a4d8ff64f4ac6f1d95f951bf7f53d6')

    if is_plat("windows", "mingw") then
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})
    end

    add_configs("openssl", {description = "with openssl library", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("openssl") then
            package:add("deps", "openssl")
        end
    end)

    on_install(function (package)
        if package:version():eq("v1.0.2") or package:version():eq("v1.1.0") then
            io.replace("CMakeLists.txt",
                "TARGET_INCLUDE_DIRECTORIES(hiredis PUBLIC $<INSTALL_INTERFACE:.>",
                "TARGET_INCLUDE_DIRECTORIES(hiredis PUBLIC $<INSTALL_INTERFACE:include>",
                {plain = true})
            if not package:config("shared") then
                -- Following change is required for package user to call `find_package(hiredis)` to work.
                io.replace("CMakeLists.txt", "ADD_LIBRARY(hiredis SHARED", "ADD_LIBRARY(hiredis", {plain = true})
                io.replace("CMakeLists.txt", "ADD_LIBRARY(hiredis_ssl SHARED", "ADD_LIBRARY(hiredis_ssl", {plain = true})
            end
        end

        local configs = {
            "-DDISABLE_TESTS=ON",
            "-DENABLE_SSL_TESTS=OFF",
        }

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DENABLE_SSL=" .. (package:config("openssl") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {buildir = "build"})

        -- hiredis cmake builds static and shared library at the same time.
        -- Remove unneeded one after install.
        if package:config("shared") then
            -- maybe is import library, libhiredis.dll.a
            if not package:is_plat("mingw") then
                os.tryrm(path.join(package:installdir("lib"), "*.a"))
            end
        else
            os.tryrm(path.join(package:installdir("lib"), "*.so"))
            os.tryrm(path.join(package:installdir("lib"), "*.so.*"))
            os.tryrm(path.join(package:installdir("lib"), "*.dylib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("redisCommand", {includes = "hiredis/hiredis.h"}))
    end)
