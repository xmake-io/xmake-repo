package("sockpp")
    set_homepage("https://github.com/fpagliughi/sockpp")
    set_description("Modern C++ socket library")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/fpagliughi/sockpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fpagliughi/sockpp.git")

    add_versions("v0.8.1", "a8aedff8bd8c1da530b91be650352008fddabc9f1df0d19701d76cbc359c8651")

    add_patches("0.8.1", path.join(os.scriptdir(), "patches", "0.8.1", "strerror.patch"), "8de819ba185c644254633d1de609e2c571c6c6f1aa7d2ac4329676ecf96fa556")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end

    if is_plat("linux") then
        add_configs("can", {description = "Build SocketCAN support.", default = false, type = "boolean"})
    end

    add_deps("cmake")

    on_install(function (package)
        local configs =
        {
            "-DSOCKPP_BUILD_STATIC=OFF",
            "-DSOCKPP_BUILD_EXAMPLES=OFF",
            "-DSOCKPP_BUILD_TESTS=OFF",
            "-DSOCKPP_BUILD_DOCUMENTATION=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DSOCKPP_BUILD_SHARED=ON")
            table.insert(configs, "-DSOCKPP_BUILD_STATIC=OFF")
        else
            table.insert(configs, "-DSOCKPP_BUILD_SHARED=OFF")
            table.insert(configs, "-DSOCKPP_BUILD_STATIC=ON")
        end
        if package:is_plat("linux") then
            table.insert(configs, "-DSOCKPP_BUILD_CAN=" .. (package:config("can") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            #include <sockpp/tcp_connector.h>
            using namespace std::chrono;
            void test() {
                std::string host = "localhost";
                in_port_t port = 12345;
                sockpp::tcp_connector conn({host, port}, seconds{5});
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
