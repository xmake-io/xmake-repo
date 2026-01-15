package("aws-lc")
    set_homepage("https://github.com/aws/aws-lc")
    set_description("AWS-LC is a general-purpose cryptographic library maintained by the AWS Cryptography team for AWS and their customers. It іs based on code from the Google BoringSSL project and the OpenSSL project.")

    add_urls("https://github.com/aws/aws-lc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/aws/aws-lc.git")

    add_versions("v1.66.2", "d64a46b4f75fa5362da412f1e96ff5b77eed76b3a95685651f81a558c5c9e126")
    add_versions("v1.66.1", "44436ec404511e822c039acd903d4932e07d2a0a94a4f0cea4c545859fa2d922")
    add_versions("v1.65.1", "d4cf3b19593fc7876b23741e8ca7c48e0043679cec393fe24b138c3f1ffd6254")
    add_versions("v1.65.0", "27d2ac24a961888efb1fcc6443ea5e611942f783e017e0c178af95d05431b808")
    add_versions("v1.64.0", "54646e5956f5394473ebe32741d2bf1509f2b556424899aed116647856f1e041")
    add_versions("v1.63.0", "8cbfe34e49c9a8ab836a72173e8b919b12dc9605252f25c667358ddc3f2d9c6b")
    add_versions("v1.53.0", "b7c3a456df40c0d19621848e8c7b70c1fa333f9e8f5aa72755890fb50c9963de")
    add_versions("v1.51.2", "7df65427f92a4c3cd3db6923e1d395014e41b1fcc38671806c1e342cb6fa02f6")
    add_versions("v1.49.1", "2fa2e31efab7220b2e0aac581fc6d4f2a6e0e16a26b9e6037f5f137d5e57b4df")
    add_versions("v1.48.5", "b3e572d09e7ef28d0b03866e610379d3a56a5940fabe6e59785ce0f874b9e959")
    add_versions("v1.48.1", "a65f79b01dc5ef3d2be743dabf5f9b72d4eda869c425348463154a5ae0746afd")
    add_versions("v1.45.0", "b136d4331583e16dbcb0c501d56e80afbe5ea1314a4a1c89056953d76e37e9fc")
    add_versions("v1.41.1", "c81376005466339564c3ca5ad83c52ca350f79391414999d052b5629d008a4d6")
    add_versions("v1.40.0", "5397a2fdb60230912dae4d7aeb3847c6b39a2f820504abbf55e376ed6a175a55")
    add_versions("v1.39.0", "37f5a379081b97adba3e1316017e09484d6c4ed6dc336d57fae6f0b7b27472fc")
    add_versions("v1.37.0", "d5ba1bd922247ce8bdd9139289bf5a021237b121e1f29a323c0ef1730cb1ed07")
    add_versions("v1.34.2", "4958ac76edd53ced46d3a064cb58be8bd11e4937bcc3857623d319c2894d0904")
    add_versions("v1.32.0", "67fbb78659055c2289c9068bb4ca1c0f1b6ca27700c7f6d34c6bc2f27cd46314")

    add_configs("jitter", {description = "Enable FIPS entropy source: CPU Jitter", default = false, type = "boolean"})
    add_configs("go", {description = "Enable go", default = false, type = "boolean"})
    add_configs("perl", {description = "Enable perl", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    if is_plat("windows", "mingw") or is_host("windows") then
        add_deps("nasm")
    end

    add_links("ssl", "crypto")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl", "m")
    end

    if on_check then
        on_check("wasm", function (target)
            if package:version() and package:version():eq("1.45.0") then
                raise("package(aws-lc 1.45.0) unsupported version")
            end
        end)
        on_check("mingw", function (target)
            if package:version() and package:version():ge("1.52.0") then
                raise("package(aws-lc >=1.52.0) unsupported version")
            end
        end)
    end

    on_load(function (package)
        if not package:is_precompiled() then
            if package:config("go") then
                package:add("deps", "go")
            end
            if is_subhost("windows") and package:config("perl") then
                package:add("deps", "strawberry-perl")
            end
        end

        if package:config("shared") and package:is_plat("windows") then
            package:add("defines", "BORINGSSL_SHARED_LIBRARY")
        end
    end)

    on_install("!cross and (!windows or windows|!arm64)", function (package)
        io.replace("CMakeLists.txt", "-WX", "", {plain = true})
        io.replace("CMakeLists.txt", [[set(C_CXX_FLAGS "${C_CXX_FLAGS} -Werror -Wformat=2 -Wsign-compare -Wmissing-field-initializers -Wwrite-strings")]], "", {plain = true})

        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
            "-DCMAKE_INSTALL_INCLUDEDIR=include",
            "-DBUILD_LIBSSL=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DENABLE_FIPS_ENTROPY_CPU_JITTER=" .. (package:config("jitter") and "ON" or "OFF"))
        table.insert(configs, "-DDISABLE_GO=" .. (package:config("go") and "OFF" or "ON"))
        table.insert(configs, "-DDISABLE_PERL=" .. (package:config("perl") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_TOOL=" .. (package:config("tools") and "ON" or "OFF"))

        local opt = {}
        if package:is_plat("mingw") and not package:is_arch64() then
            table.insert(configs, "-DOPENSSL_NO_ASM=ON")
            if package:version() and package:version():ge("1.52.0") then
                opt.cxflags = "-D_SSIZE_T_DEFINED"
            end
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SSL_new", {includes = "openssl/ssl.h"}))
    end)
