package("blake3")
    set_homepage("https://blake3.io/")
    set_description("BLAKE3 is a cryptographic hash function that is much faster than MD5, SHA-1, SHA-2, SHA-3, and BLAKE2; secure, unlike MD5 and SHA-1 (and secure against length extension, unlike SHA-2); highly parallelizable across any number of threads and SIMD lanes, because it's a Merkle tree on the inside; capable of verified streaming and incremental updates (Merkle tree); a PRF, MAC, KDF, and XOF, as well as a regular hash; and is a single algorithm with no variants, fast on x86-64 and also on smaller architectures.")
    set_license("CC0-1.0")

    add_urls("https://github.com/BLAKE3-team/BLAKE3/archive/refs/tags/$(version).tar.gz",
             "https://github.com/BLAKE3-team/BLAKE3.git")
    add_versions("1.5.1", "822cd37f70152e5985433d2c50c8f6b2ec83aaf11aa31be9fe71486a91744f37")
    add_versions("1.5.0", "f506140bc3af41d3432a4ce18b3b83b08eaa240e94ef161eb72b2e57cdc94c69")
    add_versions("1.3.3", "27d2bc4ee5945ba75434859521042c949463ee7514ff17aaef328e23ef83fec0")
    add_versions("1.3.1", "112becf0983b5c83efff07f20b458f2dbcdbd768fd46502e7ddd831b83550109")

    on_install("windows|x64", "windows|x86", "linux", "macosx", "bsd", "mingw|x86_64", "android", "iphoneos", "cross", function (package)
        local configs = {}

        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("blake3")
                set_kind("$(kind)")
                add_files("c/blake3.c", "c/blake3_dispatch.c", "c/blake3_portable.c")
                add_headerfiles("c/blake3.h")

                if is_arch("x86_64", "x64") then
                    if is_subhost("msys", "cygwin") then
                        add_files("c/*x86-64_windows_gnu.S")
                    elseif is_plat("windows") then
                        add_files("c/*x86-64_windows_msvc.asm")

                        if is_kind("shared") then
                            add_rules("utils.symbols.export_all")
                        end
                    else
                        add_files("c/*x86-64_unix.S")
                    end
                elseif is_arch("x86", "i386") then
                    add_files("c/blake3_portable.c")
                    add_files("c/blake3_sse2.c")
                    add_files("c/blake3_sse41.c")
                    add_files("c/blake3_avx2.c")
                    add_files("c/blake3_avx512.c")
                elseif is_arch("arm64", "arm64-v8a") then
                    add_files("c/blake3_neon.c")
                    add_defines("BLAKE3_USE_NEON=1")
                end
        ]])

        if package:config("shared") then
            configs.kind = "shared"
        end

        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("blake3_hasher_init", {includes = "blake3.h"}))
    end)
