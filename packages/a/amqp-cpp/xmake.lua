package("amqp-cpp")
    set_homepage("https://github.com/CopernicaMarketingSoftware/AMQP-CPP")
    set_description("C++ library for asynchronous non-blocking communication with RabbitMQ")
    set_license("Apache-2.0")

    add_urls("https://github.com/CopernicaMarketingSoftware/AMQP-CPP/archive/refs/tags/$(version).tar.gz",
             "https://github.com/CopernicaMarketingSoftware/AMQP-CPP.git")

    add_versions("v4.3.27", "af649ef8b14076325387e0a1d2d16dd8395ff3db75d79cc904eb6c179c1982fe")
    add_versions("v4.3.26", "2baaab702f3fd9cce40563dc1e23f433cceee7ec3553bd529a98b1d3d7f7911c")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    elseif is_plat("linux") then
        add_configs("tcp", {description = "Build TCP module.", default = false, type = "boolean"})
        add_syslinks("pthread", "dl")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            package:add("defines", "NOMINMAX")
            if package:config("shared") and package:version():le("4.3.26") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
        elseif package:is_plat("linux") then
            table.insert(configs, "-DAMQP-CPP_LINUX_TCP=" .. (package:config("tcp") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <amqpcpp.h>
            void test() {
                AMQP::Connection connection(nullptr, AMQP::Login("guest","guest"), "/");
                AMQP::Channel channel(nullptr);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
