package("cpp-jwt")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/arun11299/cpp-jwt")
    set_description("JSON Web Token library for C++")
    set_license("MIT")

    add_urls("https://github.com/arun11299/cpp-jwt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/arun11299/cpp-jwt.git")

    add_versions("v1.5.1", "7e5ec6891254c8f00128952ed6b9a73d827539136c3b804563521a0042abe72c")
    add_versions("v1.5", "44a59d619b0a82cae6334bb7d430d27b7fc7595e872c9f20d46aa96d2301edb2")
    add_versions("v1.4", "1cb8039ee15bf9bf735c26082d7ff50c23d2886d65015dd6b0668c65e17dd20f")

    add_deps("cmake")
    add_deps("openssl3")
    add_deps("nlohmann_json", {configs = {cmake = true}})

    on_install(function (package)
        local configs = {"-DCPP_JWT_BUILD_EXAMPLES=OFF", "-DCPP_JWT_BUILD_TESTS=OFF", "-DCPP_JWT_USE_VENDORED_NLOHMANN_JSON=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
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
