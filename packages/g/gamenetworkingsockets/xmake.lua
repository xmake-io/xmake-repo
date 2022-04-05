package("gamenetworkingsockets")

    set_homepage("https://github.com/ValveSoftware/GameNetworkingSockets")
    set_description("Reliable & unreliable messages over UDP. Robust message fragmentation & reassembly. P2P networking / NAT traversal. Encryption. ")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/ValveSoftware/GameNetworkingSockets/archive/$(version).tar.gz",
             "https://github.com/ValveSoftware/GameNetworkingSockets.git")

    add_versions("v1.4.0", "eca3b5684dbf81a3a6173741a38aa20d2d0a4d95be05cf88c70e0e50062c407b")
    add_versions("v1.3.0", "f473789ae8a8415dd1f5473793775e68a919d27eba18b9ba7d0a14f254afddf9")
    add_versions("v1.2.0", "768a7cec2491e34c824204c4858351af2866618ceb13a024336dc1df8076bef3")

    if is_plat("windows") then
        add_syslinks("ws2_32")
        add_defines("_WINDOWS", "WIN32")
    else
        add_defines("POSIX", "LINUX")
        add_syslinks("pthread")
    end

    on_load("windows", "linux", function(package)
        if not package:config("shared") then
            package:add("defines", "STEAMNETWORKINGSOCKETS_STATIC_LINK")
            if is_plat("windows") then
                package:add("deps", "libsodium", "protobuf-cpp")
            else
                package:add("deps", "openssl", "protobuf-cpp")
            end
        end
    end)

    on_install("windows", "linux", function (package)
        -- We need copy source codes to the working directory with short path on windows
        --
        -- Because the target name and source file path of this project are too long,
        -- it's absolute path exceeds the windows path length limit.
        --
        local oldir
        if is_host("windows") then
            local sourcedir = os.tmpdir() .. ".dir"
            os.tryrm(sourcedir)
            os.cp(os.curdir(), sourcedir)
            oldir = os.cd(sourcedir)
        end
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
        if oldir then
            os.cd(oldir)
        end
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("GameNetworkingSockets_Kill()", {includes = "steam/steamnetworkingsockets.h"}))
    end)
