set_xmakever("2.5.1")
set_languages("gnu11")

add_rules("mode.debug", "mode.release")

add_requires("protobuf-cpp", "openssl")

target("gns") -- we need limit path length
    set_kind("$(kind)")

    add_vectorexts("sse2")
    add_packages("protobuf-cpp", "openssl")
    set_basename("gamenetworkingsockets")

    add_defines()
    add_files("src/common/crypto_openssl.cpp",
              "src/common/crypto_25519_openssl.cpp",
              "src/common/opensslwrapper.cpp")

    if is_plat("windows") then
        add_syslinks("ws2_32")
        add_defines("WIN32", "_WINDOWS")
    else
        add_syslinks("pthread")
        add_defines("POSIX", "LINUX", "GNUC", "GNU_COMPILER")
    end

    if is_kind("shared") then
        add_defines("STEAMNETWORKINGSOCKETS_FOREXPORT")
    else
        add_defines("STEAMNETWORKINGSOCKETS_STATIC_LINK")
    end

    add_defines("STEAMNETWORKINGSOCKETS_CRYPTO_25519_OPENSSL", 
                "STEAMNETWORKINGSOCKETS_CRYPTO_VALVEOPENSSL", 
                "OPENSSL_HAS_25519_RAW""VALVE_CRYPTO_ENABLE_25519",
                "GOOGLE_PROTOBUF_NO_RTTI",
                "CRYPTO_DISABLE_ENCRYPT_WITH_PASSWORD",
                "ENABLE_OPENSSLCONNECTION")

    add_includedirs("include",
                    "src",
                    "src/common",
                    "src/tier0",
                    "src/tier1",
                    "src/vstdlib",
                    "src/steamnetworkingsockets",
                    "src/steamnetworkingsockets/clientlib",
                    "src/public")

    add_headerfiles("include/(steam/*.h)")
    add_headerfiles("include/(minbase/*.h)")
    add_headerfiles("src/public/(*/*.h)")

    add_files(  "src/common/steamnetworkingsockets_messages_certs.proto",
                "src/common/steamnetworkingsockets_messages.proto",
                "src/common/steamnetworkingsockets_messages_udp.proto", {rules = "protobuf.cpp"})
    add_files(  "src/common/crypto.cpp",
                "src/common/crypto_textencode.cpp",
                "src/common/keypair.cpp",
                "src/common/steamid.cpp",
                "src/vstdlib/strtools.cpp",
                "src/tier0/dbg.cpp",
                "src/tier0/platformtime.cpp",
                "src/tier1/bitstring.cpp",
                "src/tier1/ipv6text.c",
                "src/tier1/netadr.cpp",
                "src/tier1/utlbuffer.cpp",
                "src/tier1/utlmemory.cpp",
                "src/steamnetworkingsockets/steamnetworkingsockets_certs.cpp",
                "src/steamnetworkingsockets/steamnetworkingsockets_thinker.cpp",
                "src/steamnetworkingsockets/steamnetworkingsockets_certstore.cpp",
                "src/steamnetworkingsockets/clientlib/steamnetworkingsockets_connections.cpp",
                "src/steamnetworkingsockets/clientlib/steamnetworkingsockets_flat.cpp",
                "src/steamnetworkingsockets/clientlib/steamnetworkingsockets_lowlevel.cpp",
                "src/steamnetworkingsockets/steamnetworkingsockets_shared.cpp",
                "src/steamnetworkingsockets/steamnetworkingsockets_stats.cpp",
                "src/steamnetworkingsockets/clientlib/steamnetworkingsockets_snp.cpp",
                "src/steamnetworkingsockets/clientlib/steamnetworkingsockets_udp.cpp",
                "src/steamnetworkingsockets/clientlib/csteamnetworkingmessages.cpp",
                "src/steamnetworkingsockets/clientlib/csteamnetworkingsockets.cpp",
                "src/steamnetworkingsockets/clientlib/steamnetworkingsockets_p2p.cpp",
                "src/steamnetworkingsockets/clientlib/steamnetworkingsockets_p2p_ice.cpp")
