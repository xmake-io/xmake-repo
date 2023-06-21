package("wolfssl")
    set_homepage("https://www.wolfssl.com")
    set_description("The wolfSSL library is a small, fast, portable implementation of TLS/SSL for embedded devices to the cloud.  wolfSSL supports up to TLS 1.3!")
    set_license("GPL-2.0")

    add_urls("https://github.com/wolfSSL/wolfssl/archive/refs/tags/v$(version)-stable.tar.gz",
             "https://github.com/wolfSSL/wolfssl.git")

    add_versions("5.6.2", "eb252f6ca8d8dcc2a05926dfafbc42250fea78e5e07b4689c3fc26ad69d2dd73")
    add_versions("5.3.0", "1a3bb310dc01d3e73d9ad91b6ea8249d081016f8eef4ae8f21d3421f91ef1de9")
    

    add_configs("openssl_extra", {description = "WOLFSSL_OPENSSLEXTRA", default = false, type = "boolean"})

    add_deps("cmake")

    on_install("windows", function (package)
        local configs = {"wolfssl64.sln"}
        table.insert(configs, "/p:Configuration=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "/p:Platform=" .. (package:is_arch("x64") and "x64" or "Win32"))
        import("package.tools.msbuild").build(package, configs)
    end)


    on_install("linux", "macos", "mingw", function (package)
        local cmake_cflags = 'set(CMAKE_C_FLAGS "-Wall -Wextra -Wno-unused -Werror ${CMAKE_C_FLAGS}")'
        local new_cmake_cflags = 'set(CMAKE_C_FLAGS "-Wall -Wextra -Wno-unused ${CMAKE_C_FLAGS}")'
        io.replace("CMakeLists.txt", cmake_cflags, new_cmake_cflags, {plain = true})
        local configs = {"-DWOLFSSL_EXAMPLES=no", "-DWOLFSSL_CRYPT_TESTS=no"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DWOLFSSL_OPENSSLEXTRA=" .. (package:config("openssl_extra") and "yes" or "no"))
        local ldflags
        if package:is_plat("android") then
            ldflags = "-llog"
        end
        import("package.tools.cmake").install(package, configs, {ldflags = ldflags})
    end)

    on_test(function (package)
        assert(package:has_cincludes("wolfssl/ssl.h"))
    end)
