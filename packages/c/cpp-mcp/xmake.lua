package("cpp-mcp")
    set_homepage("https://github.com/hkr04/cpp-mcp")
    set_description("Lightweight C++ MCP (Model Context Protocol) SDK")
    set_license("MIT")

    add_urls("https://github.com/hkr04/cpp-mcp.git")
    add_versions("2025.05.24", "86856a2fcc038e05675f0649e51cd4f9d3692263")
    add_patches("2025.05.24", "patches/2025.05.24/install.diff", "ab60e1a167dbe73aefb69d4cfc5b98f4e6f6df647cfc62a3eca7b6648f41ccd0")

    add_deps("cmake")
    add_deps("pkgconf")
    add_deps("base64-terrakuh", "cpp-httplib", "nlohmann_json")

    on_install(function (package)
        os.rm("common")
        os.cp("include", package:installdir())
        local configs = {}
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
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
