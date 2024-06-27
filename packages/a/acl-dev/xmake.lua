package("acl-dev")

    set_homepage("https://github.com/acl-dev/acl")
    set_description("C/C++ server and network library")
    set_license("LGPL-3.0")

    set_urls("https://github.com/acl-dev/acl/archive/refs/tags/$(version).zip")
    set_urls("https://github.com/acl-dev/acl.git")
    add_versions("v3.6.1-7", "b80b4304b11f3b89decd276ecbdb8f7bbbe422c4b2a56eea069cb25116f24d6c")

    add_patches("v3.6.1-7", "https://github.com/acl-dev/acl/commit/353186995c44b180f316f9267ad520e362d2d7cd.patch", "b30133c15eeb24e15601ed870f422217ec42016a7890f60b662d89ca52a32d51")

    on_install(function (package)
        local configs = {}
        configs.kind = package:config("shared") and "shared" or "static"
        configs.mode = package:debug() and "debug" or "release"
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                acl::string buf = "hello world!\r\n";
            }
        ]]}, {includes = "acl_cpp/lib_acl.hpp"}))
    end)
