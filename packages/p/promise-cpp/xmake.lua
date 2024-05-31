package("promise-cpp")
    set_homepage("https://github.com/xhawk18/promise-cpp")
    set_description("C++ promise/A+ library in Javascript style.")
    set_license("MIT")

    add_urls("https://github.com/xhawk18/promise-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xhawk18/promise-cpp.git")

    add_versions("2.1.5", "9608686d0d136323396a84c2f6046060a966ed10bf4bb7895ef87340c118b66a")
    add_versions("2.1.3", "831f5c7fb36a1f0adda408898038b428d4afe96e7028947be0f755c6851eec26")

    add_configs("boost_asio", { description = "Enable boost asio.", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("boost_asio") then
            package:add("deps", "boost")
        end
    end)

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {boost_asio = package:config("boost_asio")})
    end)

    on_test(function (package)
        if package:config("boost_asio") then
            assert(package:check_cxxsnippets({test = [[
            #include <stdio.h>
            #include <boost/asio.hpp>
            #include "add_ons/asio/timer.hpp"

            using namespace promise;
            using namespace boost::asio;

            Promise myDelay(boost::asio::io_service &io, uint64_t time_ms) {
                return newPromise([&io, time_ms](Defer &d) {
                    setTimeout(io, [d](bool cancelled) {
                        if (cancelled) d.reject();
                        else d.resolve();
                    }, time_ms);
                });
            }

            Promise testTimer(io_service &io) {
                return myDelay(io, 3000).then([&] {
                    return myDelay(io, 1000);
                }).then([&] {
                    return myDelay(io, 2000);
                }).then([] {
                    printf("timer after 2000 ms!\n");
                }).fail([] {
                    printf("timer cancelled!\n");
                });
            }

            void test() {
                io_service io;
                Promise timer = testTimer(io);
                delay(io, 4500).then([=] {
                    clearTimeout(timer);
                });
                io.run();
            }
            ]]}, {configs = {languages = "c++14"}}))
        else
            assert(package:has_cxxtypes("promise::Promise", {configs = {languages = "c++14"}, includes = "promise-cpp/promise.hpp"}))
        end
    end)
