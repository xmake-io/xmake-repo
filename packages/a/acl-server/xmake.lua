package("acl-framework")

    set_homepage("https://github.com/acl-dev/acl")
    set_description("A powerful multi-platform network communication library and service framework")
    set_license("LGPL-3.0")

    set_urls("https://github.com/acl-dev/acl.git")
    add_versions("2023.11.17", "1d9386a73d0317850be27d5a94381e8c4b9ffd26")

    add_deps("cmake")

    on_load(function (package)
        if package:config("shared") then
            package:add("defines", "ACL_DLL", "HTTP_DLL", "ACL_CPP_DLL")
        end
    end)

    on_install(function (package)
        local configs = {"-DACL_BUILD_SHARED =" .. (package:config("shared") and "YES" or "NO")}
        import("package.tools.cmake").install(package, configs)
        os.cp(path.join("lib_acl_cpp", "include"), package:installdir())
        os.cp(path.join("lib_acl", "include"), package:installdir())
        os.cp(path.join("lib_fiber", "cpp", "include"), package:installdir())
        os.cp(path.join("lib_protocol", "include"), package:installdir())
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
