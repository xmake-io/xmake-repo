package("enet6")
    set_homepage("https://github.com/SirLynix/enet6")
    set_description("A fork of ENet (reliable UDP networking library) in order to add IPv6 support.")
    set_license("MIT")

    add_urls("https://github.com/SirLynix/enet6/archive/refs/tags/$(version).tar.gz",
             "https://github.com/SirLynix/enet6.git")

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
        import("package.tools.xmake").install(package)
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
