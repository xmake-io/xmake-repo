package("objfw")
    set_homepage("https://objfw.nil.im")
    set_description("Portable framework for the Objective-C language.")
    set_license("LGPL-3.0")

    add_urls("https://objfw.nil.im/downloads/objfw-$(version).tar.gz")
    add_urls("https://git.nil.im/ObjFW/ObjFW.git")

    add_versions("1.0.0",   "a6aa3bf590c6a7ae21cf13dbaa94a72926e67af5c7d5aef4a2b172543d1f26a3")
    add_versions("1.0.1",   "953fd8a7819fdbfa3b3092b06ac7f43a74bac736c120a40f2e3724f218d215f1")
    add_versions("1.0.2",   "b680be08bfade376d17958f3ceadaf223ac5d08df71a4bd787a42640a86db7cb")
    add_versions("1.0.3",   "1c81d7d03578b2d9084fc5d8722d4eaa4bdc2f3f09ce41231e7ceab8212fae17")
    add_versions("1.0.4",   "c62c61fc3f1b2d5c1d78369c602a6e82b32ade5c8ec0e9c410646d1554bf1e26")
    add_versions("1.0.5",   "798bda0590970fea10d5c8064e98088bb9960b3bc0475d92db443b0df9f205c4")
    add_versions("1.0.6",   "34eb6ee5be84d86a3de657ab17c9ee79fcfc8b3dc0d21f72917aa92378948d73")
    add_versions("1.0.7",   "9046f63abf198e7f86f888be6838cdbd367b97c696d96497cfbf4b509c1ad129")
    add_versions("1.0.8",   "935e08e296d6e409e9f7d972a04cfde82c96064d17576f36ce738d04db571c56")
    add_versions("1.0.9",   "2706af1dd584099495c68465843c4d49e613fecc57a39b565a7262ec5fae9474")
    add_versions("1.0.10",  "8963b9d2bc7bb7e1b7b5890eca2ee2e193a6036512ad72cc9244d40da3a19c67")
    add_versions("1.0.11",  "21a85cd75a508fecf77a61c12932c2b4e33c06c51f8d618743cb162a87b9af14")
    add_versions("1.0.12",  "d5f9d5dcb95c52f7b243b1b818a34be99cecaaa5afd6de1c5b2502214f5df7f7")
    add_versions("1.1.0",   "79f6a6fdc90ad6474206c8f649d66415b09a3f07b9c6ddbaf64129291fd12d94")
    add_versions("1.1.1",   "0492a08f964180b7453c05bd9f0080e70b61171a9b5194a6d1b891370c24cfc0")
    add_versions("1.1.2",   "5d9f9a70d583298e780ae11fc75a7ae2beeef904b301e1bc4f4ffa8d7ee31d9f")
    add_versions("1.1.3",   "e66ff27ac93c5747019aaa5c8a72b2e4508938e59b3ce08909e54e566ebb2e41")
    add_versions("1.1.4",   "f6bfdbab22008aae3e4b48d77ced1a04c5153961c6f7e5492891f90ae5131a78")
    add_versions("1.1.5",   "9d45d2009a0bb9b1a0918918e454b47b8161670df8016b5f3a85eccea91d8988")
    add_versions("1.1.6",   "c19a97a011e14780fb32cfbdbbd6a699a955b57124e4e079768cb8aad4430e1d")
	add_versions("1.1.7",   "5107d8a0627e2270d211abf1b4f6c50fd89c8d672d2179b50daa7d3b66d68a70")
    add_versions("1.2.0",   "f1d92b64f524a1aaf8e8b572a0edf5817d589c3d3c60cab9bb182ccbac3ee405")
    add_versions("1.2.1",   "637fdeccae149cec236e62c5289450afad542fe930343918856e76594ab3fcfd")
    add_versions("1.2.2",   "4fe0bed1ec21561a184d804aa577ff630f1e3d20b1c3b973073e23ce829294a1")
    add_versions("1.2.3",   "8324d3b352121544f817f40f71c21005457ee0255104c7e0d5aedbd6d968bced")
    add_versions("1.2.4",   "5d914e2ba6f2f0c8698be1f73752120bf2c7befed72b0f8d18c7957d415a98ab")
    add_versions("1.3",     "de9e8a84437c01dacb9e83d7de0e3f7add3152165707d51a4caec640e4f56ba6")
    add_versions("1.3.1",   "a3bdf28c2e166f97680601c29f204670a8c4c8e43d393321a7d1f64fe1d2f513")
    add_versions("1.3.2",   "8148df0d55d1a3218fe9965144b5c3ee2a7f4d8e43e430a6107e294043872cab")
    add_versions("1.4.1",   "e223b1cae37453f02ea98f085c3c1f4b78dcf7c16b43d35b05d9ad4480e175b2")
    add_versions("1.4.2",   "8e6d0cd39271130a0b6c2789fa08f2598c77d9b88acbd0e2c15c8eb1144baa08")
    add_versions("1.4.3",   "0e987c82bd482a957360a1cd7e8d14716442f9bfba68f58fef9b81750db301d9")

    if is_host("linux", "macosx") then
        add_deps("autoconf", "automake", "libtool")
        add_syslinks("pthread", "dl")
    end

    if is_plat("macosx") then
        add_syslinks("objc")
        add_frameworks("CoreFoundation")

    end

    add_configs("tls", { description = "Enable TLS support.", default = (is_plat("macosx") and "securetransport" or "openssl"), values = { true, false, "openssl", "gnutls", "securetransport", "mbedtls" } })
    add_configs("rpath", { description = "Enable rpath.", default = true, type = "boolean" })
    add_configs("runtime", { description = "Use the included runtime, not recommended for macOS!", default = not is_plat("macosx"), type = "boolean" })
    add_configs("seluid24", { description = "Use 24 bit instead of 16 bit for selector UIDs.", default = false, type = "boolean" })
    add_configs("unicode_tables", { description = "Enable Unicode tables.", default = true, type = "boolean" })

    add_configs("codepage_437", { description = "Enable codepage 437 support.", default = true, type = "boolean" })
    

    add_configs("codepage_850", { description = "Enable codepage 850 support.", default = true, type = "boolean" })
    add_configs("codepage-858", { description = "Enable codepage 858 support.", default = true, type = "boolean" })
    add_configs("iso_8859_2", { description = "Enable ISO-8859-2 support.", default = true, type = "boolean" })
    add_configs("iso_8859_3", { description = "Enable ISO-8859-3 support.", default = true, type = "boolean" })
    add_configs("iso_8859_15", { description = "Enable ISO-8859-15 support.", default = true, type = "boolean" })
    add_configs("koi8_r", { description = "Enable KOI8-R support.", default = true, type = "boolean" })
    add_configs("koi8_u", { description = "Enable KOI8-U support.", default = true, type = "boolean" })
    add_configs("mac_roman", { description = "Enable Mac Roman encoding support.", default = true, type = "boolean" })
    add_configs("windows_1251", { description = "Enable windows 1251 support.", default = true, type = "boolean" })
    add_configs("windows_1252", { description = "Enable windows 1252 support.", default = true, type = "boolean" })

    add_configs("threads", { description = "Enable threads.", default = true, type = "boolean" })
    add_configs("compiler_tls", { description = "Enable compiler thread local storage (TLS).", default = true, type = "boolean" })
    add_configs("files", { description = "Enable files.", default = true, type = "boolean" })
    add_configs("sockets", { description = "Enable sockets.", default = true, type = "boolean" })

    add_configs("arc", { description = "Enable Automatic Reference Counting (ARC) support.", default = true, type = "boolean" })

    on_load(function (package)
        local tls = package:config("tls")
        if type(tls) == "boolean" then
            if tls then
                if package:is_plat("macosx") then
                    package:add("frameworks", "Security")
                else
                    package:add("deps", "openssl")
                end
            end
        elseif tls then
            if tls == "openssl" then
                package:add("deps", "openssl")
            elseif tls == "securetransport" then
                package:add("frameworks", "Security")
            elseif tls == "gnutls" then
                package:add("deps", "gnutls")
            elseif tls == "mbedtls" then
                package:add("deps", "mbedtls")
            else
                raise("Unknown TLS library: %s", tls)
            end
        end
    end)

    on_check(function (package)
        assert(package:check_msnippets({test = [[
            void test() {
                @autoreleasepool {
                }
            }
        ]]}))
    end)

    on_install("linux", "macosx", function (package)
        local configs = {}
        local tls = package:config("tls")
        if type(tls) == "boolean" then
            tls = tls and "yes" or "no"
        end
        table.insert(configs, "--with-tls=" .. tls)
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") and name ~= "arc" then
                name = name:gsub("_", "-")
                if enabled then
                    table.insert(configs, "--enable-" .. name)
                else
                    table.insert(configs, "--disable-" .. name)
                end
            end
        end

        -- SecureTransport must be handled by system so we don't worry about providing CFLAGS and LDFLAGS,
        -- but for OpenSSL and GnuTLS we need to provide the paths
        local ssl = package:dep("openssl") or package:dep("gnutls")
        local is_gnu = ssl and ssl:name() == "gnutls"
        if ssl then
            import("lib.detect.find_library")
            import("lib.detect.find_path")

            local libssl = find_library(is_gnu and "gnutls" or "ssl", { ssl:installdir("lib"), "/usr/lib/", "/usr/lib64/", "/usr/local/lib" })
            if not libssl then
                libssl = find_library(is_gnu and "gnutls" or "ssl")
            end

            local ssl_incdir = find_path(is_gnu and "gnutls/gnutls.h" or "openssl/ssl.h", { ssl:installdir("include"), "/usr/include/", "/usr/local/include" })

            if libssl then
                table.insert(configs, "CPPFLAGS=-I"..ssl_incdir)
                table.insert(configs, "LDFLAGS=-L"..libssl.linkdir)
            else
                print("No SSL library found, using system default")
            end
        end

        import("package.tools.autoconf").install(package, configs)

        local mflags = {}
        local mxxflags = {}
        local ldflags = {}
        local objfwcfg = path.join(package:installdir("bin"), "objfw-config")
        local mflags_str = os.iorunv(objfwcfg, {"--cflags", "--cppflags", "--objcflags", (package:config("arc") and "--arc" or "")})
        local mxxflags_str = os.iorunv(objfwcfg, {"--cxxflags", "--cppflags", "--objcflags", (package:config("arc") and "--arc" or "")})
        local ldflags_str = os.iorunv(objfwcfg, {"--ldflags"})
        table.join2(mflags, mflags_str:split("%s+"))
        table.join2(mxxflags, mxxflags_str:split("%s+"))
        table.join2(ldflags, ldflags_str:split("%s+"))

        package:add("mflags", mflags)
        package:add("mxxflags", mxxflags)
        package:add("ldflags", ldflags)

        if package:config("runtime") then
            package:add("links", {"objfw", "objfwrt", (package:config("tls") and "objfwtls" or nil)})
        else
            package:add("links", {"objfw", (package:config("tls") and "objfwtls" or nil)})
        end
    end)

    on_test(function (package)
        assert(package:check_msnippets({test = [[
            void test() {
                OFString* string = @"hello";
                [OFStdOut writeLine: string];
            }
        ]]}, {includes = {"ObjFW/ObjFW.h"}}))
    end)
