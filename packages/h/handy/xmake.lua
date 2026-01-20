package("handy")
    set_homepage("https://github.com/yedf2/handy")
    set_description("A simple C++11 network server framework")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/yedf2/handy/archive/refs/tags/$(version).tar.gz",
             "https://github.com/yedf2/handy.git")

    add_versions("2023.08.19", "e58eb508ae399b539f3f64c59e9e015fa7bfd46b")

    add_deps("cmake")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 24, "package(handy) requires ndk api >= 24")
        end)
    end

    on_install("!windows and !mingw and !wasm", function (package)
        if package:is_plat("android") then
            io.replace("CMakeLists.txt", [[elseif(CMAKE_HOST_UNIX)]], [[elseif(CMAKE_HOST_UNIX OR ANDROID)]], {plain = true})
        elseif package:is_plat("bsd") then
            io.replace("handy/poller.cc", "#ifdef OS_LINUX", "#if defined(OS_LINUX) && !defined(__FreeBSD__)", {plain = true})
            io.replace("handy/poller.cc", "#elif defined(OS_MACOSX)", "#elif defined(OS_MACOSX) || defined(__FreeBSD__)", {plain = true})
            io.replace("handy/conn.cc", "#include <fcntl.h>", "#include <fcntl.h>\n#include <sys/socket.h>", {plain = true})
            io.replace("handy/udp.cc", "#include <fcntl.h>", "#include <fcntl.h>\n#include <sys/socket.h>", {plain = true})
            io.replace("handy/port_posix.cc", "#include <sys/syscall.h>", "#include <sys/syscall.h>\n#include <sys/socket.h>", {plain = true})
            io.replace("handy/port_posix.cc", [[uint64_t gettid() {
    return syscall(SYS_gettid);
}]], [[#if defined(__FreeBSD__)
#include <pthread_np.h>
uint64_t gettid() {
    return pthread_getthreadid_np();
}
#elif !defined(__FreeBSD__)
uint64_t gettid() {
    return syscall(SYS_gettid);
}
#endif]], {plain = true})
        end
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
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
