package("crow")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/CrowCpp/Crow")
    set_description("A Fast and Easy to use microframework for the web.")
    set_license("BSD 3-Clause")

    add_urls("https://github.com/CrowCpp/Crow/archive/refs/tags/$(version).zip", {version = function (version)
        return (version:gsub("%+", "."))
    end})
    add_versions("v1.2.1+1", "d9f85d9df036336c9cb872ecd73c7744e493ed5d02e9aec8b3c1351c757c9707")

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
        ]]}, {configs = {languages = "c++17"}}))
    end)
