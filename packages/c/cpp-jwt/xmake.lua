package("cpp-jwt")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/arun11299/cpp-jwt")
    set_description("JSON Web Token library for C++")
    set_license("MIT")

    add_urls("https://github.com/arun11299/cpp-jwt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/arun11299/cpp-jwt.git")

    add_versions("v1.4", "1cb8039ee15bf9bf735c26082d7ff50c23d2886d65015dd6b0668c65e17dd20f")

    add_deps("nlohmann_json", "openssl3")

    on_install("!wasm@macosx and !iphoneos@macosx and !android",function (package)
        os.cp("include/jwt", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cassert>
            #include <jwt/jwt.hpp>
            void test() {
                using namespace jwt::params;
                jwt::jwt_object obj{algorithm("HS256"), secret("secret")};
                obj.add_claim("test", "12345");
                assert(obj.has_claim("test"));
            }
        ]]}, {configs = {languages = "cxx17"}}))
    end)
