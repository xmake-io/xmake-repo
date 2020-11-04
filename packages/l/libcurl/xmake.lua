package("libcurl")

    set_homepage("https://curl.haxx.se/")
    set_description("The multiprotocol file transfer library.")

    set_urls("https://curl.haxx.se/download/curl-$(version).tar.bz2",
             "http://curl.mirror.anstey.ca/curl-$(version).tar.bz2")
    add_urls("https://github.com/curl/curl/releases/download/curl-$(version).tar.bz2",
             {version = function (version) return (version:gsub("%.", "_")) .. "/curl-" .. version end})

    add_versions("7.73.0", "cf34fe0b07b800f1c01a499a6e8b2af548f6d0e044dca4a29d88a4bee146d131")
    add_versions("7.72.0", "ad91970864102a59765e20ce16216efc9d6ad381471f7accceceab7d905703ef")
    add_versions("7.71.1", "9d52a4d80554f9b0d460ea2be5d7be99897a1a9f681ffafe739169afd6b4f224")
    add_versions("7.71.0", "600f00ac2481a89548a4141ddf983fd9386165e1960bac91d0a1c81dca5dd341")
    add_versions("7.70.0", "a50bfe62ad67a24f8b12dd7fd655ac43a0f0299f86ec45b11354f25fbb5829d0")
    add_versions("7.69.1", "2ff5e5bd507adf6aa88ff4bbafd4c7af464867ffb688be93b9930717a56c4de8")
    add_versions("7.69.0", "668d451108a7316cff040b23c79bc766e7ed84122074e44f662b8982f2e76739")
    add_versions("7.68.0", "207f54917dd6a2dc733065ccf18d61bb5bebeaceb5df49cd9445483e8623eeb9")
    add_versions("7.67.0", "dd5f6956821a548bf4b44f067a530ce9445cc8094fd3e7e3fc7854815858586c")
    add_versions("7.66.0", "6618234e0235c420a21f4cb4c2dd0badde76e6139668739085a70c4e2fe7a141")
    add_versions("7.65.3", "0a855e83be482d7bc9ea00e05bdb1551a44966076762f9650959179c89fce509")
    add_versions("7.65.2", "8093398b51e7d8337dac6f8fa6f1f77d562bdd9eca679dff9d9c3b8160ebfd28")
    add_versions("7.65.1", "cbd36df60c49e461011b4f3064cff1184bdc9969a55e9608bf5cadec4686e3f7")
    add_versions("7.65.0", "ea47c08f630e88e413c85793476e7e5665647330b6db35f5c19d72b3e339df5c")
    add_versions("7.64.1", "4cc7c738b35250d0680f29e93e0820c4cb40035f43514ea3ec8d60322d41a45d")
    add_versions("7.64.0", "d573ba1c2d1cf9d8533fadcce480d778417964e8d04ccddcc76e591d544cf2eb")
    add_versions("7.63.0", "9bab7ed4ecff77020a312d84cc5fb7eb02d58419d218f267477a724a17fd8dd8")
    add_versions("7.62.0", "7802c54076500be500b171fde786258579d60547a3a35b8c5a23d8c88e8f9620")
    add_versions("7.61.1", "a308377dbc9a16b2e994abd55455e5f9edca4e31666f8f8fcfe7a1a4aea419b9")
    add_versions("7.61.0", "5f6f336921cf5b84de56afbd08dfb70adeef2303751ffb3e570c936c6d656c9c")
    add_versions("7.60.0", "897dfb2204bd99be328279f88f55b7c61592216b0542fcbe995c60aa92871e9b")
    add_versions("7.59.0", "b5920ffd6a8c95585fb95070e0ced38322790cb335c39d0dab852d12e157b5a0")
    add_versions("7.58.0", "1cb081f97807c01e3ed747b6e1c9fee7a01cb10048f1cd0b5f56cfe0209de731")
    add_versions("7.57.0", "c92fe31a348eae079121b73884065e600c533493eb50f1f6cee9c48a3f454826")
    add_versions("7.56.1", "2594670367875e7d87b0f129b5e4690150780884d90244ba0fe3e74a778b5f90")
    add_versions("7.56.0", "de60a4725a3d461c70aa571d7d69c788f1816d9d1a8a2ef05f864ce8f01279df")
    add_versions("7.55.1", "e5b1a92ed3b0c11f149886458fa063419500819f1610c020d62f25b8e4b16cfb")
    add_versions("7.55.0", "af1d69ec6f15fe70a2cabaa98309732bf035ef2a735e4e1a3e08754d2780e5b1")
    add_versions("7.54.1", "fdfc4df2d001ee0c44ec071186e770046249263c491fcae48df0e1a3ca8f25a0")
    add_versions("7.54.0", "f50ebaf43c507fa7cc32be4b8108fa8bbd0f5022e90794388f3c7694a302ff06")
    add_versions("7.53.1", "1c7207c06d75e9136a944a2e0528337ce76f15b9ec9ae4bb30d703b59bf530e8")
    add_versions("7.53.0", "b2345a8bef87b4c229dedf637cb203b5e21db05e20277c8e1094f0d4da180801")
    add_versions("7.52.1", "d16185a767cb2c1ba3d5b9096ec54e5ec198b213f45864a38b3bda4bbf87389b")
    add_versions("7.52.0", "b9a2e18b4785eb75ad84598720e1559e1c53550ea011c0e00becdb94e2df5cc6")
    add_versions("7.51.0", "7f8240048907e5030f67be0a6129bc4b333783b9cca1391026d700835a788dde")
    add_versions("7.50.3", "7b7347d976661d02c84a1f4d6daf40dee377efdc45b9e2c77dedb8acf140d8ec")
    add_versions("7.50.2", "0c72105df4e9575d68bcf43aea1751056c1d29b1040df6194a49c5ac08f8e233")
    add_versions("7.50.1", "3c12c5f54ccaa1d40abc65d672107dcc75d3e1fcb38c267484334280096e5156")
    add_versions("7.50.0", "608dfe2db77f48db792c387e7791aca55a25f0b42385707ad927164199ecfa9a")
    add_versions("7.49.1", "eb63cec4bef692eab9db459033f409533e6d10e20942f4b060b32819e81885f1")
    add_versions("7.49.0", "14f44ed7b5207fea769ddb2c31bd9e720d37312e1c02315def67923a4a636078")
    add_versions("7.48.0", "864e7819210b586d42c674a1fdd577ce75a78b3dda64c63565abe5aefd72c753")
    add_versions("7.47.1", "ddc643ab9382e24bbe4747d43df189a0a6ce38fcb33df041b9cb0b3cd47ae98f")
    add_versions("7.47.0", "2b096f9387fb9b2be08d17e518c62b6537b1f4d4bb59111d5b4fa0272f383f66")
    add_versions("7.46.0", "b7d726cdd8ed4b6db0fa1b474a3c59ebbbe4dcd4c61ac5e7ade0e0270d3195ad")
    add_versions("7.45.0", "65154e66b9f8a442b57c436904639507b4ac37ec13d6f8a48248f1b4012b98ea")
    add_versions("7.44.0", "1e2541bae6582bb697c0fbae49e1d3e6fad5d05d5aa80dbd6f072e0a44341814")
    add_versions("7.43.0", "baa654a1122530483ccc1c58cc112fec3724a82c11c6a389f1e6a37dc8858df9")
    add_versions("7.42.1", "e2905973391ec2dfd7743a8034ad10eeb58dab8b3a297e7892a41a7999cac887")
    add_versions("7.42.0", "32557d68542f5c6cc8437b5b8a945857b4c5c6b6276da909e35b783d1d66d08f")
    add_versions("7.41.0", "9f8b546bdc5c57d959151acae7ce6610fe929d82b8d0fc5b25a3a2296e5f8bea")
    add_versions("7.40.0", "899109eb3900fa6b8a2f995df7f449964292776a04763e94fae640700f883fba")
    add_versions("7.39.0", "b222566e7087cd9701b301dd6634b360ae118cc1cbc7697e534dc451102ea4e0")
    add_versions("7.38.0", "035bd41e99aa1a4e64713f4cea5ccdf366ca8199e9be1b53d5a043d5165f9eba")
    add_versions("7.37.1", "c3ef3cd148f3778ddbefb344117d7829db60656efe1031f9e3065fc0faa25136")
    add_versions("7.37.0", "24502492de3168b0556d8e1a06f14f7589e57b204917d602a572e14239b3e09e")
    add_versions("7.36.0", "1fbe82b89bcd6b7ccda8cb0ff076edc60e911595030e27689f4abd5ef7f3cfcd")
    add_versions("7.35.0", "d774d1701454f1b7d331c2075fc4f6dd972bddc2d171f43645ef3647c7fc0d83")
    add_versions("7.34.0", "10beade56b48311499e444783df3413405b22f20a147ed4a1d8a8125f1cc829b")
    add_versions("7.33.0", "0afde4cd949e2658eddc3cda675b19b165eea1af48ac5f3e1ec160792255d1b3")
    add_versions("7.32.0", "8e3db42548e01407cb2f1407660c0f528b89ec7afda6264442fc2b229b95223b")
    add_versions("7.31.0", "a73b118eececff5de25111f35d1d0aafe1e71afdbb83082a8e44d847267e3e08")
    add_versions("7.30.0", "6b1c410387bea82601baec85d6aa61955794672e36766407e99ade8d55aaaf11")

    if is_plat("linux") then
        add_deps("openssl")
    elseif is_plat("windows") then
        add_deps("cmake")
    end

    if is_plat("macosx") then
        add_frameworks("Security", "CoreFoundation")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("windows", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_install("macosx", "linux", "iphoneos", function (package)
        local configs = {"--disable-silent-rules", "--disable-dependency-tracking", "--enable-shared=no"}
        if package:debug() then
            table.insert(configs, "--enable-debug")
        else
            table.insert(configs, "--disable-debug")
        end
        if is_plat("macosx") then
            table.insert(configs, "--with-darwinssl")
        end
        table.insert(configs, "--without-ca-bundle")
        table.insert(configs, "--without-ca-path")
        table.insert(configs, "--without-zlib")
        table.insert(configs, "--without-librtmp")
        table.insert(configs, "--disable-ares")
        table.insert(configs, "--disable-ldap")
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("curl_version", {includes = "curl/curl.h"}))
    end)
