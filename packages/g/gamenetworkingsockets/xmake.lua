package("gamenetworkingsockets")

    set_homepage("https://github.com/ValveSoftware/GameNetworkingSockets")
    set_description("Reliable & unreliable messages over UDP. Robust message fragmentation & reassembly. P2P networking / NAT traversal. Encryption. ")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/ValveSoftware/GameNetworkingSockets.git")

    add_versions("v1.6.0", "2cb93a06350bb065db53abdb0d87cf297e0bfd34")
    add_versions("v1.4.1", "1cfb2bf79c51a08ae4e8b7ff5e9c1266b43cfff6f53ecd3e7bc5e3fcb2a22503")
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

    add_configs("webrtc", {description = "Enable P2P.", default = false, type = "boolean"})
    add_configs("ice", {description = "Enable P2P/ICE.", default = false, type = "boolean"})

    on_load("windows", "linux", function(package)
        if package:version():gt("1.4.1") then
           package:add("deps", "protobuf-cpp")
           package:add("deps", "abseil")
           package:add("deps", "openssl")

           package:add("includedirs", "include", "include/GameNetworkingSockets")

           if package:config("ice") then
              package:add("defines", "STEAMNETWORKINGSOCKETS_ENABLE_ICE")
           end
        else
           package:add("deps", "protobuf-cpp <30")
           if not package:is_plat("windows") then
               package:add("deps", "openssl")
           end

           if package:config("webrtc") then
              package:add("deps", "abseil")
            end
        end

        if not package:config("shared") then
            package:add("defines", "STEAMNETWORKINGSOCKETS_STATIC_LINK")
        end
    end)

    on_install("windows|x86", "windows|x64", "linux", function (package)
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

        if package:version():le("1.4.1") then
            local configs = {}
            if package:config("shared") then
                configs.kind = "shared"
            end
            configs.webrtc = package:config("webrtc")
            os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
            import("package.tools.xmake").install(package, configs)
        else
            local configs = {}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_STATIC_LIB=" .. (not package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DBUILD_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DENABLE_ICE=" .. (package:config("ice") and "ON" or "OFF"))
            table.insert(configs, "-DUSE_STEAMWEBRTC=" .. (package:config("webrtc") and "ON" or "OFF"))
    
            local protobuf = package:dep("protobuf-cpp")
            if protobuf then
                table.insert(configs, "-DProtobuf_USE_STATIC_LIBS=" .. (protobuf:config("shared") and "OFF" or "ON"))
            end
    
            local openssl = package:dep("openssl")
            if openssl then
                table.insert(configs, "-DOPENSSL_ROOT_DIR=" .. openssl:installdir())
                table.insert(configs, "-DOPENSSL_USE_STATIC_LIBS=" .. (openssl:config("shared") and "OFF" or "ON"))
            end
    
            import("package.tools.cmake").install(package, configs)
            os.cp("lib/*.lib", package:installdir("lib"))
        end

        if oldir then
            os.cd(oldir)
        end
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("GameNetworkingSockets_Kill()", {includes = "steam/steamnetworkingsockets.h"}))
    end)
