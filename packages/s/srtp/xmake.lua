package("srtp")
    set_homepage("https://github.com/cisco/libsrtp")
    set_description("Library for SRTP (Secure Realtime Transport Protocol)")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/cisco/libsrtp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cisco/libsrtp.git")

    add_versions("v2.7", "6ef3034c8facb39bf7fe1a4ff34ba5109725cc7c27b2bcb47ac7fdc58fba49d9")
    add_versions("v2.6", "f1886f72eff1d8aa82ada40b2fc3d342a3ecaf0f8988cb63d4af234fccf2253d")
    add_versions("v2.5.0", "8a43ef8e9ae2b665292591af62aa1a4ae41e468b6d98d8258f91478735da4e09")

    add_configs("openssl", {description = "Enable OpenSSL crypto engine", default = false, type = "boolean"})
    add_configs("mbedtls", {description = "Enable MbedTLS crypto engine", default = false, type = "boolean"})
    add_configs("nss", {description = "Enable NSS crypto engine", default = false, type = "boolean", readonly = true})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libsrtp")
    elseif is_plat("linux") then
        add_extsources("pacman::libsrtp", "apt::libsrtp2-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::srtp")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("openssl") then
            package:add("deps", "openssl")
        end
        if package:config("mbedtls") then
            package:add("deps", "mbedtls")
        end
    end)

    on_install(function (package)
        local configs =
        {
            "-DLIBSRTP_TEST_APPS=OFF",
            "-DTEST_APPS=OFF",
            "-DBUILD_WITH_WARNINGS=OFF",
            "-DENABLE_WARNINGS=OFF",
            "-DENABLE_WARNINGS_AS_ERRORS=OFF",
        }

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SANITIZE_ADDR=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_LTO=" .. (package:config("lto") and "ON" or "OFF"))
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-DENABLE_" .. name:upper() .. "=" .. (enabled and "ON" or "OFF"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("srtp_init", {includes = "srtp2/srtp.h"}))
    end)
