package("node_crunch2")
    set_homepage("https://github.com/willi-kappler/node_crunch2")
    set_description("A C++ library for distributed computing.")
    set_license("MIT")

    add_deps("spdlog", "asio", "lz4", "openssl", "taocpp-json")

    add_urls("https://github.com/willi-kappler/node_crunch2/archive/refs/tags/$(version).tar.gz")
    add_versions("v0.1.0", "da214286d1a163359972ac3de021998fac4844fa903cc96e788d43831936d4ea")

    on_install(function (package)
        local configs = {}

        if package:config("shared") then
            configs.kind = "shared"
        else
            configs.kind = "static"
        end

        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end

        import("package.tools.xmake").install(package, configs)
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
    }, {configs = {languages = "c++23"}, includes = {"nc_message.hpp", "nc_config.hpp"}}))
    end)
