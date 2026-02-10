package("node_crunch2")
    set_homepage("https://github.com/willi-kappler/node_crunch2")
    set_description("A C++ library for distributed computing.")
    set_license("MIT")

    add_urls("https://github.com/willi-kappler/node_crunch2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/willi-kappler/node_crunch2.git")

    add_versions("v0.1.0", "875fd1552abdf0262c89a45772cebae52c048014b107d64912beb8ab1bb78436")

    add_patches("v0.1.0", "patches/v0.1.0/nowarn.patch", "65028d054112b190649f832e57ab985e0971d198d98a64e8694493bdfc90c818")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    add_deps("spdlog", "asio", "lz4", "openssl", "taocpp-json")

    if on_check then
        on_check(function (package)
            assert(package:check_cxxsnippets({test = [[
                #include <expected>
                void test() {
                    std::expected<int, const char*> result = 42;
                    if (result) {
                        int value = *result;
                    }
                }
            ]]}, {configs = {languages = "c++20"}}), 
            "package(node_crunch2) requires a compiler supporting C++20 with <expected> header.")
        end)
    end

    on_install("!wasm", function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        local package_std = "c++20"
        if package:is_plat("windows") then
            package_std = "c++23"
        end
        assert(package:check_cxxsnippets({
            test = [[
                using namespace NodeCrunch2;
                void test() {
                    NCNodeMessageType const message_type = NCNodeMessageType::Init;
                    NCNodeID const node_id = NCNodeID();
                    std::string const key1 = "12345678901234567890123456789012";
                    NCMessageCodecNode node_codec(key1);
                    NCMessageCodecServer server_codec(key1);
                    NCConfiguration config = NCConfiguration(key1);
                }
            ]]
        }, {configs = {languages = package_std}, includes = {"nc_message.hpp", "nc_config.hpp"}}))
    end)
