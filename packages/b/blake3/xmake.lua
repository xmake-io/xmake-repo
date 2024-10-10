package("blake3")
    set_homepage("https://blake3.io/")
    set_description("BLAKE3 is a cryptographic hash function that is much faster than MD5, SHA-1, SHA-2, SHA-3, and BLAKE2; secure, unlike MD5 and SHA-1 (and secure against length extension, unlike SHA-2); highly parallelizable across any number of threads and SIMD lanes, because it's a Merkle tree on the inside; capable of verified streaming and incremental updates (Merkle tree); a PRF, MAC, KDF, and XOF, as well as a regular hash; and is a single algorithm with no variants, fast on x86-64 and also on smaller architectures.")
    set_license("CC0-1.0")

    add_urls("https://github.com/BLAKE3-team/BLAKE3/archive/refs/tags/$(version).tar.gz",
             "https://github.com/BLAKE3-team/BLAKE3.git")

    add_versions("1.5.4", "ddd24f26a31d23373e63d9be2e723263ac46c8b6d49902ab08024b573fd2a416")
    add_versions("1.5.3", "ec9114480857334858e73b727199c573bfdbed6138a83be573f076d37e671fc1")
    add_versions("1.5.2", "1bc38cd3cc501458054c3bb473e5e00338d6175121424040079025ea305ddef3")
    add_versions("1.5.1", "822cd37f70152e5985433d2c50c8f6b2ec83aaf11aa31be9fe71486a91744f37")
    add_versions("1.5.0", "f506140bc3af41d3432a4ce18b3b83b08eaa240e94ef161eb72b2e57cdc94c69")
    add_versions("1.3.3", "27d2bc4ee5945ba75434859521042c949463ee7514ff17aaef328e23ef83fec0")
    add_versions("1.3.1", "112becf0983b5c83efff07f20b458f2dbcdbd768fd46502e7ddd831b83550109")

    if on_check then
        on_check("mingw", function (package)
            assert(package:is_arch("x86_64"), "package(blake3/mingw): Only suport x86_64 arch")
        end)
    end

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("blake3_hasher_init", {includes = "blake3.h"}))
    end)
