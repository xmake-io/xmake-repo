package("nsync")
    set_homepage("https://github.com/google/nsync")
    set_description("nsync is a C library that exports various synchronization primitives, such as mutexes")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/nsync/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/nsync.git")

    add_versions("1.30.0", "883a0b3f8ffc1950670425df3453c127c1a3f6ed997719ca1bbe7f474235b6cc")
    add_versions("1.29.2", "1d63e967973733d2c97e841e3c05fac4d3fa299f01d14c86f2695594c7a4a2ec")
    add_versions("1.29.1", "3045a8922171430426b695edf794053182d245f6a382ddcc59ef4a6190848e98")
    add_versions("1.28.1", "0011fc00820088793b6a9ba97536173a25cffd3df2dc62616fb3a2824b3c43f5")

    add_patches(">=1.30.0", "patches/1.30.0/cmake.patch", "9cb6c772cefe05af0024e8a0a6931531f000ddea3e54ad258a3b95cc04aa1e0c")
    add_patches(">=1.28.1<1.30.0", "patches/1.28.1/cmake.patch", "626a89a5a60884b7aaf44011494e7ba5dbfcdae9fcdb5afcef5b5d1f893b4600")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

    add_deps("cmake")

    on_install(function (package)
        if package:is_plat("iphoneos") then
            io.replace("CMakeLists.txt", [[elseif ("${CMAKE_SYSTEM_NAME}X" STREQUAL "DarwinX")]], "elseif(1)", {plain = true})
        end

        local configs = {"-DNSYNC_ENABLE_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nsync_mu_init", {includes = "nsync.h"}))
        assert(package:check_cxxsnippets({test = [[
            void test() {
                nsync::nsync_mu testing_mu;
                nsync::nsync_mu_init (&testing_mu);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "nsync.h"}))
    end)
