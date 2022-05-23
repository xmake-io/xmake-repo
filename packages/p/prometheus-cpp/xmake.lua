package("prometheus-cpp")
    set_homepage("https://github.com/jupp0r/prometheus-cpp")
    set_description("Prometheus Client Library for Modern C++")
    set_license("MIT")

    add_urls("https://github.com/jupp0r/prometheus-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jupp0r/prometheus-cpp.git")
    add_versions("v1.0.0", "07018db604ea3e61f5078583e87c80932ea10c300d979061490ee1b7dc8e3a41")

    local configdeps = {
        pull = {
            description = "Enable pull.",
            deps = {["civetweb"] = {version = "v1.15"}},
            links = {"prometheus-cpp-pull"},
            default = true,
        },
        push = {
            description = "Enable push.",
            deps = {["libcurl"] = {}},
            links = {"prometheus-cpp-push"},
            default = true,
        },
        compression = {
            description = "Enable compression.",
            deps = {["zlib"] = {}},
            links = nil,
            default = true,
        },
    }
    for c, o in pairs(configdeps) do
        add_configs(c, {description = o.description, default = o.default, type = type(o.default)})
    end

    add_deps("cmake")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load("linux", function (package)
        for c, o in pairs(configdeps) do
            if package:config(c) then
                for dep, depcfg in pairs(o.deps) do
                    package:add("deps", dep, depcfg)
                end
                if o.links then
                    package:add("links", o.links)
                end
            end
        end
        package:add("links", {"prometheus-cpp-core"})
    end)

    on_install("linux", function (package)
        local configs = {}

        for c, v in pairs(configdeps) do
            table.insert(configs, "-DENABLE_" .. string.upper(c) .. "=" .. (package:config(c) and "ON" or "OFF"))
        end

        table.insert(configs, "-DGENERATE_PKGCONFIG=ON")
        table.insert(configs, "-DENABLE_TESTING=OFF")
        table.insert(configs, "-DUSE_THIRDPARTY_LIBRARIES=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test("linux", function (package)
        assert(package:has_cxxincludes("prometheus/counter.h"))

        if package:config("pull") then
            assert(package:has_cxxincludes("prometheus/exposer.h"))
            assert(package:check_cxxsnippets({test = [[
                #include <array>
                #include <chrono>
                #include <cstdlib>
                #include <memory>
                #include <string>
                #include <thread>

                void test() {
                    using namespace prometheus;
                    Exposer exposer{"127.0.0.1:8080"};
                    auto registry = std::make_shared<Registry>();
                    auto& packet_counter = BuildCounter()
                        .Name("observed_packets_total")
                        .Help("Number of observed packets")
                        .Register(*registry);
                    auto& tcp_rx_counter = packet_counter.Add({{"protocol", "tcp"}, {"direction", "rx"}});
                    auto& tcp_tx_counter = packet_counter.Add({{"protocol", "tcp"}, {"direction", "tx"}});
                    auto& udp_rx_counter = packet_counter.Add({{"protocol", "udp"}, {"direction", "rx"}});
                    auto& udp_tx_counter = packet_counter.Add({{"protocol", "udp"}, {"direction", "tx"}});
                    auto& http_requests_counter = BuildCounter()
                        .Name("http_requests_total")
                        .Help("Number of HTTP requests")
                        .Register(*registry);
                    exposer.RegisterCollectable(registry);
                    for (int i = 0; i < 30; i++) {
                        std::this_thread::sleep_for(std::chrono::seconds(1));
                        const auto random_value = std::rand();
                        if (random_value & 1) tcp_rx_counter.Increment();
                        if (random_value & 2) tcp_tx_counter.Increment();
                        if (random_value & 4) udp_rx_counter.Increment();
                        if (random_value & 8) udp_tx_counter.Increment();
                        const std::array<std::string, 4> methods = {"GET", "PUT", "POST", "HEAD"};
                        auto method = methods.at(random_value % methods.size());
                        http_requests_counter.Add({{"method", method}}).Increment();
                    }
                }
            ]]}, {configs = {languages = "cxx11"}, includes = {"prometheus/counter.h", "prometheus/exposer.h", "prometheus/registry.h"}}))
        end

        if package:config("push") then
            assert(package:has_cxxincludes("prometheus/gateway.h"))
        end
    end)