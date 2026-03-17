package("librats")
    set_homepage("https://github.com/DEgITx/librats")
    set_description("High-performance, lightweight p2p native library for big networks")
    set_license("MIT")

    set_urls("https://github.com/DEgITx/librats/archive/refs/tags/$(version).tar.gz",
             "https://github.com/DEgITx/librats.git")

    add_versions("0.8.0", "6223839f884eea16ed10128e0b88bc96374397cce3f24e5ee35324a0e2c4d3c7")
    add_versions("0.5.4", "1abf6aca56add96311a7e99490bc966180e2e919b4a8a581f0c068aed7eff91d")
    add_versions("0.4.0", "df1cc354d960a9cf6fd88c4b72939b975d67a1da5513f7a59aa38c1129b81b25")
    add_versions("0.3.1", "6a368a5d17a3ee9b97825ed6ee8df2ef46d7dde1c27937ce78c2b90a32b49148")
    add_versions("0.3.0", "01e7e323e75ef7ef3b93a3025c7c2f31e37a42ebe414ec707cd500e054754e4b")
    add_versions("0.2.1", "32cc19dde006a54efdf642f54053d3506cb78815ca5b2db5c4d2c30104d33fc8")
    add_versions("0.1.5", "6e026e66c8a339f383a15ad1243d48acea601d91e584e146b8472cfc17709946")

    add_configs("bindings", {description = "Enable C API bindings for FFI support.", default = false, type = "boolean"})
    add_configs("search", {description = "Enable Rats Search feature (like Bittorrent / DHT spider algorithm).", default = false, type = "boolean"})
    add_configs("storage", {description = "Enable distributed key-value storage with P2P synchronization.", default = false, type = "boolean"})

    add_deps("cmake")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(librats) require ndk api level > 21")
        end)
    end

    on_load(function (package)
        if package:is_plat("windows", "mingw") then
            package:add("syslinks", "ws2_32", "iphlpapi", "bcrypt")
        elseif package:is_plat("linux") then
            package:add("syslinks", "pthread")
        end
        if package:is_plat("windows") then
            local version = package:version()
            if version and version:lt("0.3.1") then
                package:config_set("shared", false)
                wprint("package(librats <0.3.1) only support static library on windows.")
            end
        end
    end)

    on_install("!wasm and !bsd and (!windows or windows|!arm64)", function (package)
        local file = io.open("CMakeLists.txt", "a")
        file:write([[

            include(GNUInstallDirs)
            install(TARGETS rats)
            install(DIRECTORY src/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
        ]])
        file:close()

        local configs = {"-DBUILD_TESTS=OFF", "-DRATS_BUILD_EXAMPLES=OFF", "-DRATS_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DRATS_SHARED_LIBRARY=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DRATS_STATIC_LIBRARY=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DRATS_BINDINGS=" .. (package:config("bindings") and "ON" or "OFF"))
        table.insert(configs, "-DRATS_SEACH_FEATURES=" .. (package:config("search") and "ON" or "OFF"))  -- for 0.4.0 & 0.3.1
        table.insert(configs, "-DRATS_SEARCH_FEATURES=" .. (package:config("search") and "ON" or "OFF"))
        table.insert(configs, "-DRATS_STORAGE=" .. (package:config("storage") and "ON" or "OFF"))
        if package:is_plat("android", "cross") then
            table.insert(configs, "-DRATS_CROSSCOMPILING=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "librats.h"
            void test() {
                librats::RatsClient client(8080);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
