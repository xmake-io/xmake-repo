package("restinio")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Stiffstream/restinio")
    set_description("Cross-platform, efficient, customizable, and robust asynchronous HTTP/WebSocket server C++14 library with the right balance between performance and ease of use")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Stiffstream/restinio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Stiffstream/restinio.git", {version = function (version) return "v." .. tostring(version) end})

    add_versions("0.6.17", "0140b23f50bb964f6917d1f99205476eba92203dc586673bdf2ea48d7406f2c4")
    add_versions("0.6.18", "16fa041f4603746c6cd0f29ab126d02d220034535e7019c6ca1b8b9f58bfeee0")
    add_versions("0.6.19", "5a739cac8f3148e7e94f05bb08f5cf569dd31f6f3ea2b893eddfffb0a155eb52")

    if is_plat("mingw") then
        add_syslinks("ws2_32", "mswsock")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake",
             "asio",
             "http_parser",
             "fmt",
             "expected-lite",
             "optional-lite",
             "string-view-lite",
             "variant-lite")

    add_defines("RESTINIO_EXTERNAL_EXPECTED_LITE",
                "RESTINIO_EXTERNAL_OPTIONAL_LITE",
                "RESTINIO_EXTERNAL_STRING_VIEW_LITE",
                "RESTINIO_EXTERNAL_VARIANT_LITE")

    on_install("windows", "linux", "macosx", "bsd", "mingw", "msys", "android", "iphoneos", "cross", function (package)
        os.cd("dev/restinio")
        local configs =
        {
            "-DRESTINIO_INSTALL=ON",
            "-DRESTINIO_USE_EXTERNAL_EXPECTED_LITE=ON",
            "-DRESTINIO_USE_EXTERNAL_OPTIONAL_LITE=ON",
            "-DRESTINIO_USE_EXTERNAL_STRING_VIEW_LITE=ON",
            "-DRESTINIO_USE_EXTERNAL_VARIANT_LITE=ON",
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
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
        ]]}, {configs = {languages = "c++14"}}))
    end)
