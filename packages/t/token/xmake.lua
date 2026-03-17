package("token")
    set_homepage("https://gitlab.kitware.com/utils/token")
    set_description("Utilities for string tokenization. Tokens (string hashes) can be used in place of the strings themselves for fast dictionary key lookup in the place of length string comparators and improve security when used carefully to avoid unnecessary string processing.")
    set_license("BSD-3-Clause")

    add_urls("https://gitlab.kitware.com/utils/token.git")
    add_versions("24.09.0", "24.09")

    add_deps("cmake")
    add_deps("nlohmann_json", {configs = {cmake = true}})

    on_load(function (package)
        package:add("includedirs", "include/token/" .. package:version())
    end)

    on_install("windows", "linux", "bsd", "macosx", function (package)
        io.replace("token/CMakeLists.txt", "foreach (class ${classes})", [[
                    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/CxxABIConfigure.h"
                            DESTINATION include/token/${token_VERSION}/token)
                    foreach (class ${classes})]], {plain = true})
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <token/Token.h>
            #include <token/Manager.h>
            void test() {
                std::shared_ptr<token::Manager> manager(new token::Manager);
                auto h = manager->manage("fooset");
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
