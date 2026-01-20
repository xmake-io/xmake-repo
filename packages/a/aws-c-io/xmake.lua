package("aws-c-io")
    set_homepage("https://github.com/awslabs/aws-c-io")
    set_description("This is a module for the AWS SDK for C. It handles all IO and TLS work for application protocols. ")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-io/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-io.git")

    add_versions("v0.26.0", "27591a4d67b7401dc0b87f8fec91b1c93764decb32229086113c80d4d6d6d3c0")
    add_versions("v0.23.3", "cdcb31b694fc28ba96237ee33a742679daf2dcabfd41464f8a68fbd913907085")
    add_versions("v0.23.2", "3a335b812411c30bcc64072f148ddf6cd632d8261799cd04e54051b44506feb9")
    add_versions("v0.22.0", "07b0ac7271e482e1f5f1e84fcf33ec23fb8a2c12e7a7f331455a5f1d38b9fbfd")
    add_versions("v0.21.2", "75ada840ed7ef1b8e6908a9d2d017375f9093b9db04c51caf68f8edcfd20cc4c")
    add_versions("v0.21.1", "1d4c6ac5d65acdad8c07f7b0bdd417fd52ab99d29d6d79788618eba317679cf1")
    add_versions("v0.21.0", "31232dd35995c9d5d535f3cf5ce7d561d680285a0e2a16318d4f0d4512b907c4")
    add_versions("v0.20.1", "8e2abf56e20f87383c44af6818235a12f54051b40c98870f44b2d5d05be08641")
    add_versions("v0.19.1", "f2fea0c066924f7fe3c2b1c7b2fa9be640f5b16a6514854226330e63a1faacd0")
    add_versions("v0.18.1", "65d275bbde1a1d287cdcde62164dc015b9613a5525fe688e972111d8a3b568fb")
    add_versions("v0.18.0", "c65a9f059dfe3208dbc92b7fc11f6d846d15e1a14cd0dabf98041ce9627cadda")
    add_versions("v0.17.0", "edf8dbd19704685f7400c6fc3fcb875ab858b1e55382c7ec933efddff28b2332")
    add_versions("v0.15.3", "d8cb4d7d3ec4fb27cbce158d6823a1f2f5d868e116f1d6703db2ab8159343c3f")
    add_versions("v0.15.1", "70f119b44f2758fc482872141cb712122f1c3c82fea16d203b7286a98c139a71")
    add_versions("v0.15.0", "a8fbc39721395c12fd66bf2ce39b4cac24df395b35700b9ae718a7923d229df4")
    add_versions("v0.14.19", "127aa30608084affbcc0b7b26982ab4d98404d1aa103b91693d0e76b564da21d")
    add_versions("v0.14.18", "44e9dee181ed7d867d1cc2944f4b4669259b569fc56bdd6dd4c7c30440fc4bf8")
    add_versions("v0.14.16", "bf78ab5dbeeaec2f55cb035e18c49ce8ba4e2ea7519e8b94e18ccd8851e39f4d")
    add_versions("v0.14.14", "c62400e83232e6d7c04bacebf02d552f6699d90735d9b8b6ee5fae879735c458")
    add_versions("v0.14.13", "1c228b1ed327e3a8518b89702ac0d93265cf50788038091e187c697cace7fa5a")
    add_versions("v0.14.9", "3a3b7236f70209ac12b5bafa7dd81b75cc68b691a0aa0686d6d3b7e4bbe5fbc9")
    add_versions("v0.14.8", "d50e21fdbd5170a4071fe067ef4ce297b02cb058ad47e118305e25f6e07d9cf0")
    add_versions("v0.14.7", "ecf1f660d7d43913aa8a416be6a2027101ce87c3b241344342d608335b4df7d4")
    add_versions("v0.14.6", "bb3af305af748185b1c7b17afa343e54f2d494ccff397402f1b17041b0967865")
    add_versions("v0.14.5", "2700bcde062f7de1c1cbfd236b9fdfc9b24b4aa6dc0fb09bb156e16e07ebd0b6")
    add_versions("v0.13.32", "2a6b18c544d014ca4f55cb96002dbbc1e52a2120541c809fa974cb0838ea72cc")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("windows","mingw") then
        add_syslinks("advapi32", "crypt32", "secur32", "ncrypt")
    elseif is_plat("linux", "bsd", "cross", "android") then
        add_deps("s2n-tls")
    elseif is_plat("macosx", "iphoneos") then
        add_frameworks("Security", "Network")
    end

    add_deps("cmake", "aws-c-common", "aws-c-cal")

    on_install("!wasm and (!mingw or mingw|!i386)", function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "USE_WINDOWS_DLL_SEMANTICS", "AWS_IO_USE_IMPORT_EXPORT")
        end

        local cmakedir = path.unix(package:dep("aws-c-common"):installdir("lib", "cmake"))

        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
            "-DCMAKE_MODULE_PATH=" .. cmakedir,
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SANITIZERS=" .. (package:config("asan") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DAWS_STATIC_MSVC_RUNTIME_LIBRARY=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "*.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aws_io_library_init", {includes = "aws/io/io.h"}))
    end)
