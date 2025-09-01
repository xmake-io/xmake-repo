package("librats")
    set_homepage("https://github.com/DEgITx/librats")
    set_description("High-performance, lightweight p2p native library for big networks")
    set_license("MIT")

    set_urls("https://github.com/DEgITx/librats/archive/refs/tags/$(version).tar.gz",
             "https://github.com/DEgITx/librats.git")

    add_versions("0.2.1", "32cc19dde006a54efdf642f54053d3506cb78815ca5b2db5c4d2c30104d33fc8")
    add_versions("0.1.5", "6e026e66c8a339f383a15ad1243d48acea601d91e584e146b8472cfc17709946")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "iphlpapi", "bcrypt")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(librats) require ndk api level > 21")
        end)
    end

    on_install("windows|!arm*", "linux", "macosx", "cross", function (package)
        local file = io.open("CMakeLists.txt", "a")
        file:write([[
            include(GNUInstallDirs)
            install(TARGETS rats)
            install(DIRECTORY src/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
        ]])
        file:close()

        local configs = {"-DBUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <librats.h>
            void test() {
                // Create client with automatic NAT traversal
                librats::NatTraversalConfig nat_config;
                nat_config.enable_ice = true;
                nat_config.enable_turn_relay = true;
                
                librats::RatsClient client(8080, 10, nat_config);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
