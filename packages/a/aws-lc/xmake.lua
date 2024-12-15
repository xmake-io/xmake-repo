package("aws-lc")
    set_homepage("https://github.com/aws/aws-lc")
    set_description("AWS-LC is a general-purpose cryptographic library maintained by the AWS Cryptography team for AWS and their customers. It іs based on code from the Google BoringSSL project and the OpenSSL project.")

    add_urls("https://github.com/aws/aws-lc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/aws/aws-lc.git")

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

    on_load(function (package)
        if package:config("go") then
            package:add("deps", "go")
        end
        if package:config("perl") and package:is_plat() and (not package:is_precompiled()) then
            package:add("deps", "strawberry-perl")
        end
    end)

    on_install("!cross and windows|!arm64", function (package)
        if package:config("shared") and package:is_plat("windows") then
            package:add("defines", "BORINGSSL_SHARED_LIBRARY")
        end

        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DCMAKE_INSTALL_INCLUDEDIR=include",
            "-DBUILD_LIBSSL=ON",
        }

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DENABLE_FIPS_ENTROPY_CPU_JITTER=" .. (package:config("jitter") and "ON" or "OFF"))
        table.insert(configs, "-DDISABLE_GO=" .. (package:config("go") and "OFF" or "ON"))
        table.insert(configs, "-DDISABLE_PERL=" .. (package:config("perl") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_TOOL=" .. (package:config("tools") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SSL_new", {includes = "openssl/ssl.h"}))
    end)
