package("aws-c-io")
    set_homepage("https://github.com/awslabs/aws-c-io")
    set_description("This is a module for the AWS SDK for C. It handles all IO and TLS work for application protocols. ")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-io/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-io.git")

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
        add_frameworks("Security")
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
