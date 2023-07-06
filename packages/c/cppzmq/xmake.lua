package("cppzmq")
    set_kind("library", {headeronly = true})
    set_homepage("http://www.zeromq.org/")
    set_description("Header-only C++ binding for libzmq")
    set_license("MIT")

    add_urls("https://github.com/zeromq/cppzmq/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zeromq/cppzmq.git")
    add_versions("v4.8.1", "7a23639a45f3a0049e11a188e29aaedd10b2f4845f0000cf3e22d6774ebde0af")
    add_versions("v4.9.0", "3fdf5b100206953f674c94d40599bdb3ea255244dcc42fab0d75855ee3645581")
    add_versions("v4.10.0", "c81c81bba8a7644c84932225f018b5088743a22999c6d82a2b5f5cd1e6942b74")

    add_deps("cmake", "zeromq")

    on_install("windows", "macosx", "linux", function (package)
        import("package.tools.cmake").install(package, {"-DCPPZMQ_BUILD_TESTS=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets([[
            void test() {
                zmq::context_t ctx;
                zmq::socket_t sock(ctx, zmq::socket_type::push);
                sock.bind("inproc://test");
                sock.send(zmq::str_buffer("Hello, world"), zmq::send_flags::dontwait);
            }
        ]], {configs = {languages = "c++14"}, includes = "zmq.hpp"}))
    end)
