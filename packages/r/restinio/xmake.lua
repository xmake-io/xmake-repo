package("restinio")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Stiffstream/restinio")
    set_description("Cross-platform, efficient, customizable, and robust asynchronous HTTP/WebSocket server C++14 library with the right balance between performance and ease of use")
    set_license("BSD-3-Clause")

    -- the release tag is v.0.7.4 for 0.7.4 and older, but v0.7.5 for 0.7.5 and newer
    local function tag(version)
        return "v" .. (version:ge("0.7.5") and "" or ".") .. tostring(version)
    end

    add_urls("https://github.com/Stiffstream/restinio/archive/refs/tags/$(version).tar.gz", {version = tag})
    add_urls("https://github.com/Stiffstream/restinio.git", {version = tag})

    add_versions("0.7.10", "f680281dfdf211172746869e6b975ba7a417c0ab659611dfc28483af30d64d6c")
    add_versions("0.7.0", "1d6ad5812c02ee42342ed0ed78678a4e37c1cfe87f2f7c32c2862f825062feaa")
    add_versions("0.6.17", "0140b23f50bb964f6917d1f99205476eba92203dc586673bdf2ea48d7406f2c4")
    add_versions("0.6.18", "16fa041f4603746c6cd0f29ab126d02d220034535e7019c6ca1b8b9f58bfeee0")
    add_versions("0.6.19", "5a739cac8f3148e7e94f05bb08f5cf569dd31f6f3ea2b893eddfffb0a155eb52")

    if is_plat("mingw") then
        add_syslinks("ws2_32", "mswsock")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake", "expected-lite")

    on_load(function (package)
        -- fmt 12.2.0 and later is unsupported on mingw/i386
        local fmt = package:is_plat("mingw") and package:is_arch("i386", "x86") and "fmt <12.2.0" or "fmt"
        -- restinio before 0.7.4 uses the deprecated asio APIs removed in asio 1.33.0,
        -- e.g. asio::buffer_cast and asio::socket_base::max_connections
        local asio = package:version():ge("0.7.4") and "asio" or "asio <1.33"
        if package:version():ge("0.7.0") then
            -- restinio 0.7.x requires C++17 and uses llhttp instead of http_parser
            package:add("deps", asio, "llhttp", fmt)
        else
            package:add("deps", asio, "http_parser", fmt,
                                   "optional-lite", "string-view-lite", "variant-lite")
            package:add("defines", "RESTINIO_EXTERNAL_EXPECTED_LITE",
                                    "RESTINIO_EXTERNAL_OPTIONAL_LITE",
                                    "RESTINIO_EXTERNAL_STRING_VIEW_LITE",
                                    "RESTINIO_EXTERNAL_VARIANT_LITE")
        end
    end)

    on_install("windows", "linux", "macosx", "bsd", "mingw", "msys", "android", "iphoneos", "cross", function (package)
        os.cd("dev/restinio")
        local configs = {"-DRESTINIO_INSTALL=ON"}
        if package:version():ge("0.7.0") then
            table.join2(configs,
            {
                "-DRESTINIO_ASIO_SOURCE=standalone",
                "-DRESTINIO_DEP_STANDALONE_ASIO=system",
                "-DRESTINIO_DEP_LLHTTP=system",
                "-DRESTINIO_DEP_FMT=system",
                "-DRESTINIO_DEP_EXPECTED_LITE=system",
            })
        else
            table.join2(configs,
            {
                "-DRESTINIO_USE_EXTERNAL_EXPECTED_LITE=ON",
                "-DRESTINIO_USE_EXTERNAL_OPTIONAL_LITE=ON",
                "-DRESTINIO_USE_EXTERNAL_STRING_VIEW_LITE=ON",
                "-DRESTINIO_USE_EXTERNAL_VARIANT_LITE=ON",
            })
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local cppstd = package:version():ge("0.7.0") and "c++17" or "c++14"
        assert(package:check_cxxsnippets({test = [[
            #include <restinio/all.hpp>
            void test() {
                restinio::run(
                    restinio::on_this_thread()
                    .port(8080)
                    .address("localhost")
                    .request_handler([](auto req) {
                        return req->create_response().set_body("Hello, World!").done();
                    }));
            }
        ]]}, {configs = {languages = cppstd}}))
    end)
