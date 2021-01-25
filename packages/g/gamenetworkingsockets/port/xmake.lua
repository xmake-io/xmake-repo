set_xmakever("2.5.1")
set_languages("cxx11")

add_rules("mode.debug", "mode.release")
if is_mode("release") then
    add_ldflags("/LTCG", "/OPT:REF")
    add_cxflags("/Ot", "/GL", "/Ob2", "/Oi", "/GS-")
    add_defines("NDEBUG")
    set_optimize("fastest")
end

add_requires("protobuf-cpp", is_plat("windows") and {} or {configs = {cxflags = "-fpic"}})
if is_plat("windows") then
    add_requires("libsodium")
else
    add_requires("openssl", {configs = {cxflags = "-fpic"}})
end

target("gamenetworkingsockets")
    set_kind("$(kind)")

    add_vectorexts("sse2")
    add_packages("protobuf-cpp")

    if is_plat("windows") then
        add_packages("libsodium")
        add_syslinks("ws2_32")
        add_defines("WIN32", "_WINDOWS", "STEAMNETWORKINGSOCKETS_CRYPTO_LIBSODIUM", "STEAMNETWORKINGSOCKETS_CRYPTO_25519_LIBSODIUM")
        add_files(  "src/common/crypto_libsodium.cpp",
                    "src/common/crypto_25519_libsodium.cpp")
    else
        add_packages("openssl")
        add_defines("STEAMNETWORKINGSOCKETS_CRYPTO_25519_OPENSSL", "STEAMNETWORKINGSOCKETS_CRYPTO_VALVEOPENSSL", "OPENSSL_HAS_25519_RAW")
        add_defines("POSIX", "LINUX", "GNUC", "GNU_COMPILER")
        add_cxxflags("-fPIC")
        add_files(  "src/common/crypto_openssl.cpp",
                    "src/common/crypto_25519_openssl.cpp",
                    "src/common/opensslwrapper.cpp")
    end

    if is_kind("shared") then
        add_defines("STEAMNETWORKINGSOCKETS_FOREXPORT")
    else
        add_defines("STEAMNETWORKINGSOCKETS_STATIC_LINK")
    end

    add_defines("VALVE_CRYPTO_ENABLE_25519",
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

    add_files(  "src/common/*.proto", {rules = "protobuf.cpp"})
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
