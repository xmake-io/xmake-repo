package("enet6")
    set_homepage("https://github.com/SirLynix/enet6")
    set_description("A fork of ENet (reliable UDP networking library) in order to add IPv6 support.")
    set_license("MIT")

    add_urls("https://github.com/SirLynix/enet6/archive/refs/tags/$(version).tar.gz",
             "https://github.com/SirLynix/enet6.git")

    add_versions("v6.1.3", "58276a1c17aebd090886229de8537f93317a9abe880b8377ce800891778bb12d")
    add_versions("v6.1.2", "fab3da9d3bb03312463dd2336ecf8bdc36093df3984364b4b85c2a7b1296cfaa")
    add_versions("v6.1.0", "d4cdf02651d0b7c48150b07dba127951141f8c52a8ae002c1056dc6a018a6d10")
    add_versions("v6.0.2", "e4678f2d22ea689b7de66bffb553c9f60d429051f44ca6177e8364eb960c7503")
    add_versions("v6.0.1", "8df91f35d2edc78113924de95946680175007e249c3afd401ec4ad9a1e9572d9")
    add_versions("v6.0.0", "4a6358fcf81a0011d7342349d60941201f88c1c88f124f583a502e4591030a88")

    if is_plat("windows", "mingw") then
        add_syslinks("winmm", "ws2_32")
    end

    on_load("windows", "mingw", function (package)
        if package:config("shared") then
            package:add("defines", "ENET_DLL")
        end
    end)

    on_install(function (package)
        local configs = {}
        configs.examples = false
        import("package.tools.xmake").install(package, configs)
   end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test()
            {
                if (enet_initialize () != 0)
                    return;

                ENetAddress address;
                ENetHost* server;
                enet_address_build_any(&address, ENET_ADDRESS_TYPE_IPV6);
                address.port = 1234;
                server = enet_host_create (ENET_ADDRESS_TYPE_ANY, &address, 32, 2, 0, 0);
                if (server == NULL)
                    return;

                ENetEvent event;
                while (enet_host_service (server, &event, 1000) > 0);

                enet_host_destroy(server);
                enet_deinitialize();
            }
        ]]}, {includes = {"enet6/enet.h"}}))
    end)
