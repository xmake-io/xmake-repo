package("acl-server")

    set_homepage("https://github.com/acl-dev/acl")
    set_description("A powerful multi-platform network communication library and service framework")
    set_license("LGPL-3.0")

    set_urls("https://github.com/acl-dev/acl/archive/refs/tags/v$(version).tar.gz")
    add_versions("3.6.1-6", "7bafe00fe6b9601953b95b4d9a80f3421fac44365d452de31936c98517c5a23a")

    on_install(function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include "acl_cpp/lib_acl.hpp"
            void test() {
                acl::string buf = "hello world!\r\n";
                std::cout << buf.c_str() << std::endl;
            }
        ]]}))
    end)
