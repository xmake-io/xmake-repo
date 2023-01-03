package("handy")
    set_homepage("https://github.com/yedf2/handy")
    set_description("A simple C++11 network server framework")

    add_urls("https://github.com/yedf2/handy/archive/refs/tags/$(version).tar.gz",
             "https://github.com/yedf2/handy.git")
    add_versions("0.2.0", "831d9e7cdf94d19fbc8438e75dc6c63fa75777ff2f83ac48df981c22e924a2d1")

    add_deps("cmake")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("linux", "macosx", "iphoneos", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_HANDY_SHARED_LIBRARY=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_HANDY_STATIC_LIBRARY=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <handy/handy.h>
            using namespace handy;
            void test() {
                EventBase base;
                Signal::signal(SIGINT, [&]{ base.exit(); });
                TcpServerPtr svr = TcpServer::startServer(&base, "", 2099);
                exitif(svr == NULL, "start tcp server failed");
                svr->onConnRead([](const TcpConnPtr& con) {
                    con->send(con->getInput());
                });
                base.loop();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
