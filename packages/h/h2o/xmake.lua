package("h2o")
    set_homepage("https://h2o.examp1e.net")
    set_description("H2O - the optimized HTTP/1, HTTP/2, HTTP/3 server")
    set_license("MIT")

    add_urls("https://github.com/h2o/h2o.git")

    add_versions("2026.06.29", "edd7a120bfc4af11ac0cbebce2a43cc1f93f9af1")
    add_versions("v2.2.6", "7359e98d78d018a35f5da7523feac69f64eddb4b")

    add_deps("cmake", "openssl", "zlib")

    add_configs("mruby", {description = "whether or not to build with mruby support", default = false, type = "boolean"})
    add_configs("ccache", {description = "whether or not to build using ccache", default = false, type = "boolean"})
    add_configs("dtrace", {description = "use USDT (userspace Dtrace probes)", default = false, type = "boolean"})
    add_configs("fusion", {description = "build with fusion AES-GCM engine", default = false, type = "boolean", readonly = true})
    add_configs("uv", {description = "Build with uv support.", default = true, type = "boolean"})
    add_configs("uring", {description = "whether or not to use io_uring", default = false, type = "boolean"})
    add_configs("ktls", {description = "use Kernel TLS", default = true, type = "boolean"})
    add_configs("aegis", {description = "enable AEGIS", default = false, type = "boolean", readonly = true})
    add_configs("mptcp", {description = "whether or not to support listening on MPTCP sockets", default = true, type = "boolean"})
    add_configs("brotli", {description = "whether or not to use brotli", default = false, type = "boolean"})
    add_configs("zstd", {description = "whether or not to use zstd", default = false, type = "boolean"})

    -- CMakeLists.txt forces -g3 -O2
    add_patches("2026.06.29", "patches/2026.06.29/c-flags.patch", "1a410958f145eea305f9e0b975611faf034c907733e5bfb57f4098583aaa3509")
    add_patches("v2.2.6", "patches/v2.2.6/c-flags.patch", "6b39b402cdbe47f56baa147a56f04222e2daea7e2f5757cce08a80bf5ee3ea31")

    on_check("linux", function (package)
        -- the bug is not related to xmake
        assert(not (package:is_debug() and package:config("shared")), "package(h2o): the package cannot be built in shared and debug mode at the same time")
    end)

    on_load(function (package)
        if package:config("uring") then
            package:add("deps", "liburing")
        end
        if package:config("uv") then
            package:add("deps", "libuv")
        end
        if package:config("brotli") then
            package:add("deps", "brotli")
        end
        if package:config("zstd") then
            package:add("deps", "zstd")
        end

        package:add("defines", "H2O_USE_LIBUV=" .. (package:config("uv") and "1" or "0"))
    end)

    on_install("linux", function (package)
        local configs = {}

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_MRUBY=" .. (package:config("mruby") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_CCACHE=" .. (package:config("ccache") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_DTRACE=" .. (package:config("dtrace") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_FUSION=" .. (package:config("fusion") and "ON" or "OFF"))
        table.insert(configs, "-DDISABLE_LIBUV=" .. (package:config("uv") and "OFF" or "ON"))
        table.insert(configs, "-DWITH_IO_URING=" .. (package:config("uring") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_KTLS=" .. (package:config("ktls") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_AEGIS=" .. (package:config("aegis") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_MPTCP=" .. (package:config("mptcp") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_BROTLI=" .. (package:config("brotli") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_ZSTD=" .. (package:config("zstd") and "ON" or "OFF"))
        
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                h2o_globalconf_t config;
                h2o_config_init(&config);
            }
        ]]}, {configs = {languages = "c99"}, includes = "h2o.h"}))
    end)
