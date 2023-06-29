package("crow")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/CrowCpp/Crow")
    set_description("A Fast and Easy to use microframework for the web.")
    set_license("BSD 3-Clause")

    set_urls("https://github.com/CrowCpp/Crow.git")
    add_versions("2023.06.26", "13a91a1941fbabfc289dddcdeab08b80193f7c6c")

    add_configs("zlib", {description = "ZLib for HTTP Compression", default = true, type = "boolean"})
    add_configs("ssl", {description = "OpenSSL for HTTPS support", default = true, type = "boolean"})

    add_deps("cmake", "asio")

    on_load(function (package)
        if package:config("zlib") then
            package:add("deps", "zlib")
        end
        if package:config("ssl") then
            package:add("deps", "openssl")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        local configs = {"-DCROW_BUILD_EXAMPLES=OFF", "-DCROW_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        local features = {}
        if package:config("zlib") then
            table.insert(features, "compression")
        end
        if package:config("ssl") then
            table.insert(features, "ssl")
        end
        if #features > 0 then
            table.insert(configs, '-DCROW_FEATURES="' .. table.concat(features, ";") .. '"')
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "crow.h"

            void test()
            {
                crow::SimpleApp app;
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
