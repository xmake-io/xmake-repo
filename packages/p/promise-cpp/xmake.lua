package("promise-cpp")
    set_homepage("https://github.com/xhawk18/promise-cpp")
    set_description("C++ promise/A+ library in Javascript style.")
    set_license("MIT")

    add_urls("https://github.com/xhawk18/promise-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xhawk18/promise-cpp.git")
    add_versions("2.1.3", "831f5c7fb36a1f0adda408898038b428d4afe96e7028947be0f755c6851eec26")

    add_deps("cmake", "boost")
    add_includedirs("include", "include/promise-cpp")

    on_install("linux", "macosx", "windows", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DPROMISE_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "add_subdirectory(./example/mfc_timer)", {plain = true})
        io.replace("CMakeLists.txt", [[add_executable(asio_benchmark_test ${my_headers} example/asio_benchmark_test.cpp)
    target_compile_definitions(asio_benchmark_test PRIVATE BOOST_ALL_NO_LIB)  
    target_link_libraries(asio_benchmark_test PRIVATE promise)

    add_executable(asio_timer ${my_headers} example/asio_timer.cpp)
    target_compile_definitions(asio_timer PRIVATE BOOST_ALL_NO_LIB)  
    target_link_libraries(asio_timer PRIVATE promise)

    add_executable(asio_http_client ${my_headers} example/asio_http_client.cpp)
    target_compile_definitions(asio_http_client PRIVATE BOOST_ALL_NO_LIB)  
    target_link_libraries(asio_http_client PRIVATE promise)

    add_executable(asio_http_server ${my_headers} example/asio_http_server.cpp)
    target_compile_definitions(asio_http_server PRIVATE BOOST_ALL_NO_LIB)  
    target_link_libraries(asio_http_server PRIVATE promise)]], "", {plain = true})
        import("package.tools.cmake").install(package, configs, {buildir = "build"})
        os.cp("include", package:installdir())
        os.cp("add_ons", package:installdir("include"))
        print(os.files(package:installdir("lib") .. "/**.a"))
        print(os.files(package:installdir("lib") .. "/**.so"))
        print(os.files(package:installdir("lib") .. "/**.lib"))
        print(os.files("build/**.a"))
        print(os.files("build/**.so"))
        print(os.files("build/**.lib"))
    end)

    on_test(function (package)
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
    end)

