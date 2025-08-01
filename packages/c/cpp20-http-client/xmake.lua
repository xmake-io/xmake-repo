package("cpp20-http-client")
    set_homepage("https://github.com/avocadoboi/cpp20-http-client")
    set_description("An HTTP(S) client library for C++20.")
    set_license("MIT")

    add_urls("https://github.com/avocadoboi/cpp20-http-client.git")

    add_versions("2023.08.11", "bb011a055a1813a4fb2a0b67db0ffa455221aaf8")
    add_versions("2025.07.24", "2c0efb938486c3edb81705c4abe6486457d9d88f")

    if is_plat("windows") then
        add_syslinks("ws2_32", "crypt32")
    else
        add_deps("openssl")
    end

    if on_check then
        on_check(function (package)
            assert(package:check_cxxsnippets({test = [[
                #include <format>
                void test() {
                    auto f = std::format("Hello, {}!", "world");
                }
            ]]}, {configs = {languages = "c++20"}}), "package(cpp20-http-client) requires c++20")
        end)
    end

    on_install("windows", "linux", "macosx", "bsd", "android", "cross", function (package)
        if package:is_plat("bsd") then
            io.replace("source/cpp20_http_client.cpp", [[#	include <netinet/tcp.h>]], [[#	include <netinet/tcp.h>
#	include <netinet/in.h>]], {plain = true})
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            if not is_plat("windows") then
                add_requires("openssl")
            end
            set_languages("c++20")
            target("cpp20-http-client")
                set_kind("$(kind)")
                add_files("source/**.cpp")
                add_includedirs("include")
                add_headerfiles("include/**.hpp")
                if is_plat("windows") then
                    add_cxxflags("/utf-8")
                    add_syslinks("ws2_32", "crypt32")
                    if is_kind("shared") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                    end
                else
                    add_packages("openssl")
                end
        ]])
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cpp20_http_client.hpp>
            void test() {
                auto const response = http_client::get("https://www.google.com")
                    .add_header({.name="HeaderName", .value="header value"})
                    .send();
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
