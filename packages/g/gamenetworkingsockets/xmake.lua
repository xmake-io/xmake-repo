package("gamenetworkingsockets")

    set_homepage("https://github.com/ValveSoftware/GameNetworkingSockets")
    set_description("Reliable & unreliable messages over UDP. Robust message fragmentation & reassembly. P2P networking / NAT traversal. Encryption. ")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/ValveSoftware/GameNetworkingSockets/archive/$(version).tar.gz",
             "https://github.com/ValveSoftware/GameNetworkingSockets.git")

    add_versions("v1.2.0", "768a7cec2491e34c824204c4858351af2866618ceb13a024336dc1df8076bef3")

    on_load("windows", "linux", function(package)
        if not package:config("shared") then
            package:add("defines", "STEAMNETWORKINGSOCKETS_STATIC_LINK")
            if is_plat("windows") then
                package:add("deps", "libsodium", "protobuf-cpp")
                package:add("syslinks", "ws2_32")
            else
                package:add("deps", "openssl", "protobuf-cpp", {configs = {cxflags = "-fpic"}})
            end
        end
    end)

    on_install("windows", "linux", function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)

        os.cp("include/*", package:installdir("include"))
        os.cp("src/public", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
                #include <steam/steamnetworkingsockets.h>

                void test() {
                    GameNetworkingSockets_Kill();
                }
            ]]}))
    end)
