package("libsais")
    set_homepage("https://github.com/IlyaGrebnov/libsais")
    set_description("libsais is a library for linear time suffix array, longest common prefix array and burrows wheeler transform construction based on induced sorting algorithm.")
    set_license("Apache-2.0")

    add_urls("https://github.com/IlyaGrebnov/libsais/archive/refs/tags/$(version).tar.gz",
             "https://github.com/IlyaGrebnov/libsais.git")
    add_versions("v2.10.2", "e2fe778b69dcd9e4a1df57b8eefb577f803788336855b6a5f9fbf22683f3980e")
    add_versions("v2.10.1", "ecf4611c18fefd8d4377343e4dc3f257ae17a501301a13f7cb7585c836405d39")
    add_versions("v2.10.0", "25c80c99945d7148b61ee4108dbda77e3dda605619ebfc7b880fd074af212b50")
    add_versions("v2.8.7", "c957a6955eac415088a879459c54141a2896edc9b40c457899ed2c4280b994c8")
    add_versions("v2.8.4", "6de93b078a89ea85ee03916a7a9cfb1003a9946dee9d1e780a97c84d80b49476")
    add_versions("v2.8.3", "9f407265f7c958da74ee8413ee1d18143e3040c453c1c829b10daaf5d37f7cda")
    add_versions("v2.8.2", "a17918936d6231cf6b019629d65ad7170f889bab5eb46c09b775dede7d890502")
    add_versions("v2.8.1", "01852e93305fe197d8f2ffdc32a856e78d6796aa3f40708325084c55b450747a")
    add_versions("v2.8.0", "71f608d1e2a28652e66076f42becc3bbd3e0c8a21ba11a4de226a51459e894a9")
    add_versions("v2.7.5", "613c597b64fb096738d4084e0f2eb3b490aded7295cffc7fb23bdccc30097ebf")
    add_versions("v2.7.3", "45d37dc12975c4d40db786f322cd6dcfd9f56a8f23741205fcd0fca6ec0bf246")
    add_versions("v2.7.1", "5f459ad90cd007c30aaefb7d122bba2a4307ea02915c56381be4b331cca92545")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("libsais")
               set_kind("$(kind)")
               add_files("src/*.c")
               add_includedirs("include")
               add_headerfiles("include/(*.h)")
               add_headerfiles("src/(*.h)")
               if is_plat("windows") and is_kind("shared") then
                    add_defines("LIBSAIS_SHARED", "LIBSAIS_EXPORTS")
               end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libsais_create_ctx", {includes = "libsais.h"}))
    end)
