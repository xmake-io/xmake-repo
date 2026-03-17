package("blake3")
    set_homepage("https://blake3.io/")
    set_description("BLAKE3 is a cryptographic hash function that is much faster than MD5, SHA-1, SHA-2, SHA-3, and BLAKE2; secure, unlike MD5 and SHA-1 (and secure against length extension, unlike SHA-2); highly parallelizable across any number of threads and SIMD lanes, because it's a Merkle tree on the inside; capable of verified streaming and incremental updates (Merkle tree); a PRF, MAC, KDF, and XOF, as well as a regular hash; and is a single algorithm with no variants, fast on x86-64 and also on smaller architectures.")
    set_license("CC0-1.0")

    add_urls("https://github.com/BLAKE3-team/BLAKE3/archive/refs/tags/$(version).tar.gz",
             "https://github.com/BLAKE3-team/BLAKE3.git")

    add_versions("1.8.3", "5a11e3f834719b6c1cae7aced1e848a37013f6f10f97272e7849aa0da769f295")
    add_versions("1.8.2", "6b51aefe515969785da02e87befafc7fdc7a065cd3458cf1141f29267749e81f")
    add_versions("1.8.1", "fc2aac36643db7e45c3653fd98a2a745e6d4d16ff3711e4b7abd3b88639463dd")
    add_versions("1.6.1", "1f2fbd93790694f1ad66eef26e23c42260a1916927184d78d8395ff1a512d285")
    add_versions("1.5.5", "6feba0750efc1a99a79fb9a495e2628b5cd1603e15f56a06b1d6cb13ac55c618")
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
