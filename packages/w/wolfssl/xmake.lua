package("wolfssl")
    set_homepage("https://www.wolfssl.com")
    set_description("The wolfSSL library is a small, fast, portable implementation of TLS/SSL for embedded devices to the cloud.  wolfSSL supports up to TLS 1.3!")
    set_license("GPL-2.0")

    add_urls("https://github.com/wolfSSL/wolfssl/archive/refs/tags/v$(version)-stable.tar.gz",
             "https://github.com/wolfSSL/wolfssl.git")

    add_versions("5.7.2", "0f2ed82e345b833242705bbc4b08a2a2037a33f7bf9c610efae6464f6b10e305")
    add_versions("5.6.6", "3d2ca672d41c2c2fa667885a80d6fa03c3e91f0f4f72f87aef2bc947e8c87237")
    add_versions("5.6.4", "031691906794ff45e1e792561cf31759f5d29ac74936bc8dffb8b14f16d820b4")
    add_versions("5.6.3", "2e74a397fa797c2902d7467d500de904907666afb4ff80f6464f6efd5afb114a")
    add_versions("5.6.2", "eb252f6ca8d8dcc2a05926dfafbc42250fea78e5e07b4689c3fc26ad69d2dd73")
    add_versions("5.3.0", "1a3bb310dc01d3e73d9ad91b6ea8249d081016f8eef4ae8f21d3421f91ef1de9")
    
    add_configs("quic", {description = "Enable QUIC support", default = false, type = "boolean"})
    add_configs("curl", {description = "Enable CURL support", default = false, type = "boolean"})
    add_configs("asio", {description = "Enable asio support", default = false, type = "boolean"})
    add_configs("oqs", {description = "Enable integration with the OQS (Open Quantum Safe) liboqs library", default = false, type = "boolean"})
    add_configs("openssl_extra", {description = "Enable extra OpenSSL API, size+", default = false, type = "boolean"})
    add_configs("openssl_all", {description = "Enable all OpenSSL API, size++", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "crypt32", "advapi32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    elseif is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation", "Security")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("shared") then
            package:add("defines", "WOLFSSL_DLL")
        end
        if package:config("oqs") then
            package:add("deps", "liboqs")
        end
    end)

    on_install("!windows or windows|!arm64", function (package)
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})

        local configs = {"-DWOLFSSL_EXAMPLES=no", "-DWOLFSSL_CRYPT_TESTS=no"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DWOLFSSL_DEBUG=" .. (package:is_debug() and "yes" or "no"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DWOLFSSL_EXPERIMENTAL=" .. (package:config("oqs") and "yes" or "no"))

        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, format("-DWOLFSSL_%s=%s", name:upper(), (enabled and "yes" or "no")))
            end
        end

        local opt = {}
        if package:is_plat("android") then
            opt.ldflags = "-llog"
        end
        import("package.tools.cmake").install(package, configs, opt)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "*.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("wolfSSL_Init", {includes = "wolfssl/ssl.h"}))
    end)
