set_xmakever("2.5.1")
set_languages("cxx11")

add_rules("mode.debug", "mode.release")

add_requires("protobuf-cpp")
if is_plat("windows") then
    add_requires("libsodium")
else
    add_requires("openssl")
end

-- there may be a dependency order between proto files, we can only disable parallel compilation
-- TODO xmake will fix `rule("protobuf.cpp")` in v2.5.2
rule("protobuf.cpp.disable_parallel")
    set_extensions(".proto")
    before_build_files(function (target, sourcebatch, opt)
        if target:is_plat("windows") then
            winos.cmdargv = function (argv, key)

                -- too long arguments?
                local limit = 1024
                local argn = 0
                for _, arg in ipairs(argv) do
                    argn = argn + #arg
                    if argn > limit then
                        break
                    end
                end
                if argn > limit then
                    local argsfile = os.tmpfile(key or table.concat(argv, '')) .. ".args.txt"
                    local f = io.open(argsfile, 'w')
                    if f then
                        -- we need split args file to solve `fatal error LNK1170: line in command file contains 131071 or more characters`
                        -- @see https://github.com/xmake-io/xmake/issues/812       
                        local idx = 1
                        while idx <= #argv do
                            arg = args[idx]
                            if idx + 1 <= #argv and arg:find("^[-/]") and not argv[idx + 1]:find("^[-/]") then
                                f:write(os.args(arg, {escape = true}) .. " ")
                                f:write(os.args(argv[idx + 1], {escape = true}) .. "\n")
                                idx = idx + 2
                            else
                                f:write(os.args(arg, {escape = true}) .. "\n")
                                idx = idx + 1
                            end
                        end
                        f:close()
                    end
                    argv = {"@" .. argsfile}
                    io.cat(argsfile)
                end
                return argv
            end
        end
        import("rules.protobuf.proto", {rootdir = os.programdir(), alias = "build_proto"})
        for _, sourcefile in ipairs(sourcebatch.sourcefiles) do
            build_proto(target, "cxx", sourcefile, opt)
        end
    end)
rule_end()

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
        add_syslinks("pthread")
        add_defines("STEAMNETWORKINGSOCKETS_CRYPTO_25519_OPENSSL", "STEAMNETWORKINGSOCKETS_CRYPTO_VALVEOPENSSL", "OPENSSL_HAS_25519_RAW")
        add_defines("POSIX", "LINUX", "GNUC", "GNU_COMPILER")
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

    add_headerfiles("include/(steam/*.h)")
    add_headerfiles("include/(minbase/*.h)")
    add_headerfiles("src/public/(*/*.h)")

    add_files(  "src/common/steamnetworkingsockets_messages_certs.proto",
                "src/common/steamnetworkingsockets_messages.proto",
                "src/common/steamnetworkingsockets_messages_udp.proto", {rules = "protobuf.cpp.disable_parallel"})
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
