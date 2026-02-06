package("node_crunch2")
    set_homepage("https://github.com/willi-kappler/node_crunch2")
    set_description("A C++ library for distributed computing.")
    set_license("MIT")

    add_urls("https://github.com/willi-kappler/node_crunch2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/willi-kappler/node_crunch2.git")

    add_versions("v0.1.0", "875fd1552abdf0262c89a45772cebae52c048014b107d64912beb8ab1bb78436")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    add_deps("spdlog", "asio", "lz4", "openssl", "taocpp-json")

    on_install(function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
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
        }, {configs = {languages = "c++20"}, includes = {"nc_message.hpp", "nc_config.hpp"}}))
    end)
