package("cpp-mcp")
    set_homepage("https://github.com/hkr04/cpp-mcp")
    set_description("Lightweight C++ MCP (Model Context Protocol) SDK")
    set_license("MIT")

    add_urls("https://github.com/hkr04/cpp-mcp.git")
    add_versions("2025.05.24", "86856a2fcc038e05675f0649e51cd4f9d3692263")
    add_patches("2025.05.24", "patches/2025.05.24/install.diff", "81944d0bd25899834876f5f4cf99d10f8f45fb8d31dd7838d6500c08956d5941")

    add_configs("openssl", {description = "Enable openssl", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("pkgconf")
    add_deps("base64-terrakuh", "cpp-httplib", "nlohmann_json")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end

    on_load(function (package)
        if package:config("openssl") then
            package:add("deps", "openssl3")
        end
    end)

    on_install(function (package)
        os.rm("common")
        os.cp("include", package:installdir())
        local configs = {}
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMCP_SSL=" .. (package:config("openssl") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "mcp_server.h"
            void test() {
                mcp::server server("localhost", 8080);
                server.set_server_info("MCP Example Server", "0.1.0");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
