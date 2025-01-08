package("cosmocc")
    set_kind("toolchain")
    set_homepage("https://github.com/jart/cosmopolitan")
    set_description("build-once run-anywhere c library")
    set_license("ISC")

    add_urls("https://cosmo.zip/pub/cosmocc/cosmocc-$(version).zip",
             "https://justine.lol/cosmopolitan/cosmocc-$(version).zip",
             "https://github.com/xmake-mirror/cosmopolitan/releases/download/$(version)/cosmocc-$(version).zip")

    add_versions("3.2.4", "d2fa6dbf6f987310494581deff5b915dbdc5ca701f20f7613bb0dcf1de2ee511")
    add_versions("3.3.2", "a695012ffbeac5e26e3c4a740debc15273f47e9a8bdc55e8b76a623154d5914b")
    add_versions("3.3.4", "98e5b361c525603f5296351e0c11820fd25908b52fe1ce8ff394d66b1537a259")
    add_versions("3.3.5", "db78fd8d3f8706e9dff4be72bf71d37a3f12062f212f407e1c33bc4af3780dd0")
    add_versions("3.3.6", "26e3449357f31b82489774ef5c2d502a711bb711d4faf99a5fd6c96328a1c205")
    add_versions("3.3.7", "638c2c2d9ba968c240e296b3cf901ac60d3a6d9205eff68356673db47a94d836")
    add_versions("3.3.8", "61208872dea249fb9621e950a15f438d2db70b0ca3aa3e91f5e8d0b078fc328d")
    add_versions("3.3.9", "0a8a781710f58373077a91ca16a2fafc30a0bc3982fb9b9c5583f045833eca36")
    add_versions("3.3.10", "00d61c1215667314f66e288c8285bae38cc6137fca083e5bba6c74e3a52439de")
    add_versions("3.4.0", "475e24b84a18973312433f5280e267acbe1b4dac1b2e2ebb3cfce46051a8c08c")
    add_versions("3.5.0", "6c8443078ce43bf15bb835c8317d6d44e694e1572023263359c082afb7ec2224")
    add_versions("3.5.1", "ea1f47cd4ead6ce3038551be164ad357bd45a4b5b7824871c561d2af23f871d6")
    add_versions("3.5.2", "69d319eb6f5e9f2581949e60cea8e419e0d7d4095c0c79ac627f5a77490f6240")
    add_versions("3.5.3", "4f0850a01a2d83417de21ee79bea09ffddeab4bf9061b072ddbe5522a28d73c6")
    add_versions("3.5.4", "1e822906021a5eb56172b4e89840c0b0cd7db97b718355a41414b4ca913171e0")
    add_versions("3.5.5", "c48f405298885fbd37737b4cc75e75ead9bd159346c948068cf6e724a01c40e9")
    add_versions("3.5.6", "efdc021d1825a27830a45e88d408668c08f22dcb7f6a1ca289fdaf77a937aa66")
    add_versions("3.5.7", "596876951b62ad2530c63afc40edd805d751fcb2416e544d249af04ad00bb4ed")
    add_versions("3.5.8", "80bea0e523b666d4d4e74fb729ac1e4bd924d1b9f2892d939af62ae2c4a0f622")
    add_versions("3.5.9", "1f66831de4bf2d82e138d8993e9ee84a7559afc47aeeb2e2de51872401790a0a")
    add_versions("3.6.0", "4918c45ac3e0972ff260e2a249e25716881e39fb679d5e714ae216a2ef6c3f7e")
    add_versions("3.6.1", "5f46bdfa4db8326794306d1a0348efc01e199f53b262bc05aa92b37be09a3f3a")
    add_versions("3.6.2", "268aa82d9bfd774f76951b250f87b8edcefd5c754b8b409e1639641e8bd8d5bc")
    add_versions("3.7.0", "871cfffd2e4ee3fc55d6f8d8583c6d73669f8412eea604830c8ecb74f89d6aef")
    add_versions("3.7.1", "13b65b0e659b493bd82f3d0a319d0265d66f849839e484aa2a54191024711e85")
    add_versions("3.8.0", "813c6b2f95062d2e0a845307a79505424cb98cb038e8013334f8a22e3b92a474")
    add_versions("3.9.0", "814ab13782191c40b80f081242db3fd850a4ea35122c7ee9da434c36e9444c6a")
    add_versions("3.9.1", "5eabd964554cc592d707d553697a450272290c07b88cc2e9503a299e00a13584")
    add_versions("3.9.2", "f4ff13af65fcd309f3f1cfd04275996fb7f72a4897726628a8c9cf732e850193")
    add_versions("3.9.3", "37cfb39217b980b04dc256dc9a4ae55646c371a1b0e63d5a1e45bed3cc14ceae")
    add_versions("3.9.4", "04d2aca686e3b780f8dadbee2750bac28fdcca2aaedcc97375fb91bd38f94bdd")
    add_versions("3.9.5", "83b0f9120a581d85dcafeb2bb5900b872c8d2c01ddcbc6816e7a69ad748a7659")
    add_versions("3.9.6", "cb9611df6aa156f0bd94a10976dbd694cf137985d70a963be717e1cfb66fa19e")
    add_versions("3.9.7", "3f559555d08ece35bab1a66293a2101f359ac9841d563419756efa9c79f7a150")
    add_versions("4.0.0", "15d8ab4442c94ce925f1d59884c772ab817af5e2889549c21ce5fa11c5d773bc")
    add_versions("4.0.1", "aa9cde34c082d92fb736cc0a1178cdf955894b9e0f80db75e4dea8e5b8ed7238")
    add_versions("4.0.2", "85b8c37a406d862e656ad4ec14be9f6ce474c1b436b9615e91a55208aced3f44")
    

    set_policy("package.precompiled", false)

    on_load("@windows|x64", function (package)
        package:add("deps", "msys2")
    end)

    on_install("@windows", "@macosx", "@linux", "@bsd", "@cygwin", "@msys", function (package)
        if is_host("windows") then
            import("lib.detect.find_tool")
            assert(find_tool("sh"), "cosmocc need sh/bash, please install it first!")
        end
        os.cp("*", package:installdir(), {symlink = true})
        -- fix symlinks for windows
        if is_host("windows") then
            os.cp("bin/cosmocc", path.join(package:installdir("bin"), "cosmoc++"))
        end
    end)

    on_test(function (package)
        local cosmocc = path.join(package:installdir("bin"), "cosmocc")
        local cosmocxx = path.join(package:installdir("bin"), "cosmoc++")
        os.vrunv(cosmocc, {"--version"}, {shell = true})
        os.vrunv(cosmocxx, {"--version"}, {shell = true})
    end)
