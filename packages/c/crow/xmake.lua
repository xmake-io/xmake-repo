package("crow")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/CrowCpp/Crow")
    set_description("A Fast and Easy to use microframework for the web.")
    set_license("BSD 3-Clause")

    add_urls("https://github.com/CrowCpp/Crow/archive/refs/tags/$(version).zip", {version = function (version)
        return (version:gsub("%+", "."))
    end})
    add_versions("v1.3.1", "5dad8aa6bf5784d3c9ff98cb692166e593c9c972b49c409f8af4833473443a6c")
    add_versions("v1.3.0", "da99fcf439a3725c5bd48a4d6c04a7994163e1c711003ec5aa881c2e4156763e")
    add_versions("v1.2.1+2", "eb52839043358830e09976198df5c1e8855a75730ccd3f1d8799eff0a79609b1")
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

    on_install("!wasm", function (package)
        local configs = {"-DCROW_BUILD_EXAMPLES=OFF", "-DCROW_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DCROW_ENABLE_COMPRESSION=" .. (package:config("zlib") and "ON" or "OFF"))
        table.insert(configs, "-DCROW_ENABLE_SSL=" .. (package:config("ssl") and "ON" or "OFF"))
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
