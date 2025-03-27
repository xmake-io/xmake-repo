package("acl-dev")
    set_homepage("https://acl-dev.cn")
    set_description("C/C++ server and network library, including coroutine,redis client,http/https/websocket,mqtt, mysql/postgresql/sqlite client with C/C++ for Linux, Android, iOS, MacOS, Windows, etc..")
    set_license("LGPL-3.0")

    add_urls("https://github.com/acl-dev/acl/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/acl-dev/acl.git")

    add_versions("3.6.2", "888fd9b8fb19db4f8e7760a12a28f37f24ba0a2952bb0409b8380413a4b6506b")

    add_includedirs("include", "include/acl-lib")

    on_install(function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                acl::string buf = "hello world!\r\n";
            }
        ]]}, {includes = "acl_cpp/lib_acl.hpp"}))
    end)
