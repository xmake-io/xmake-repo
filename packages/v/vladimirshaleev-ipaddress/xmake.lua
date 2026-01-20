package("vladimirshaleev-ipaddress")
    set_kind("library", {headeronly = true})
    set_homepage("https://vladimirshaleev.github.io/ipaddress/")
    set_description("A library for working and manipulating IPv4/IPv6 addresses and networks")
    set_license("MIT")

    add_urls("https://github.com/VladimirShaleev/ipaddress/archive/refs/tags/$(version).tar.gz",
             "https://github.com/VladimirShaleev/ipaddress.git")

    add_versions("v1.2.1", "7ad9af8218ad3e96c348d100706b1f5a02706ff49be811913ee2a438ddfa61d2")
    add_versions("v1.2.0", "c3a52e5297d8f0b152c13b04ea2aead0bb9bc2a963188d740d87c78e770daba1")
    add_versions("v1.1.0", "e5084d83ebd712210882eb6dac14ed1b9b71584dede523b35c6181e0a06375f1")

    add_configs("exceptions", {description = "Support handling cpp exception", default = true, type = "boolean"})
    add_configs("overload_std", {description = "Overload std functions such as to_string, hash etc", default = true, type = "boolean"})
    add_configs("ipv6_scope", {description = "Support scope id for IPv6 addresses", default = true, type = "boolean"})
    add_configs("ipv6_scope_max_length", {description = "Maximum scope-id length for IPv6 addresses", default = 16, type = "number"})

    add_deps("cmake")

    on_load(function (package)
        if not package:config("exceptions") then
            package:add("defines", "IPADDRESS_NO_EXCEPTIONS")
        end
        if not package:config("overload_std") then
            package:add("defines", "IPADDRESS_NO_OVERLOAD_STD")
        end
        if not package:config("ipv6_scope") then
            package:add("defines", "IPADDRESS_NO_IPV6_SCOPE")
            package:add("defines", "IPADDRESS_IPV6_SCOPE_MAX_LENGTH=0")
        else
            package:add("defines", "IPADDRESS_IPV6_SCOPE_MAX_LENGTH=" .. package:config("ipv6_scope_max_length"))
        end
    end)

    on_install(function(package)
        local configs = {"-DBUILD_TESTING=OFF", "-DIPADDRESS_ENABLE_CLANG_TIDY=OFF", "-DIPADDRESS_BUILD_TESTS=OFF",
                         "-DIPADDRESS_BUILD_BENCHMARK=OFF", "-DIPADDRESS_BUILD_DOC=OFF",
                         "-DIPADDRESS_BUILD_PACKAGES=OFF"}

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DIPADDRESS_NO_EXCEPTIONS=" .. (package:config("exceptions") and "OFF" or "ON"))
        table.insert(configs, "-DIPADDRESS_NO_OVERLOAD_STD=" .. (package:config("overload_std") and "OFF" or "ON"))
        table.insert(configs, "-DIPADDRESS_NO_IPV6_SCOPE=" .. (package:config("ipv6_scope") and "OFF" or "ON"))
        table.insert(configs, "-DIPADDRESS_IPV6_SCOPE_MAX_LENGTH=" .. package:config("ipv6_scope_max_length"))

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function(package)
        if package:config("overload_std") then
            assert(package:check_cxxsnippets({test = [[
                #include <iostream>
                #include <ipaddress/ipaddress.hpp>
                using namespace ipaddress;
                void parse_ip_sample() {
                    constexpr auto ip = ipv6_address::parse("fec0::1ff:fe23:4567:890a%eth2");
                    std::cout << "DNS PTR " << ip.reverse_pointer() << std::endl << std::endl;
                }
                void teredo_sample() {
                    constexpr auto teredo_ip = "2001:0000:4136:e378:8000:63bf:3fff:fdd2"_ipv6;
                    auto [server, client] = teredo_ip.teredo().value();
                    std::cout << "server: " << server << " and client: " << client << " for " << teredo_ip << std::endl << std::endl;
                }
            ]]
            }, {configs = {languages = "c++17"}}))
        else
            assert(package:check_cxxsnippets({test = [[
                #include <ipaddress/ipaddress.hpp>
                using namespace ipaddress;
                auto test_no_overload() {
                    constexpr auto ip = ipv6_address::parse("fec0::1ff:fe23:4567:890a%eth2");
                    return ip;
                }
            ]]
            }, {configs = {languages = "c++17"}}))
        end
    end)
