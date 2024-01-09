package("objfw")
    set_homepage("https://objfw.nil.im")
    set_description("Portable framework for the Objective-C language.")

    add_urls("https://objfw.nil.im/downloads/objfw-$(version).tar.gz")
    add_versions("1.0.0", "55f7d9e99b8e2d4e0e193b2f0275501e6d9c1ebd29cadbea6a0da48a8587e3e0")
    add_versions("1.0.1", "953fd8a7819fdbfa3b3092b06ac7f43a74bac736c120a40f2e3724f218d215f1")
    add_versions("1.0.2", "b680be08bfade376d17958f3ceadaf223ac5d08df71a4bd787a42640a86db7cb")
    add_versions("1.0.3", "1c81d7d03578b2d9084fc5d8722d4eaa4bdc2f3f09ce41231e7ceab8212fae17")
    add_versions("1.0.4", "c62c61fc3f1b2d5c1d78369c602a6e82b32ade5c8ec0e9c410646d1554bf1e26")
    add_versions("1.0.5", "798bda0590970fea10d5c8064e98088bb9960b3bc0475d92db443b0df9f205c4")

    if is_host("linux", "macosx") then
        add_deps("autoconf", "automake", "libtool")
    end

    if is_plat("macosx") then
        add_syslinks("objc")
        add_frameworks("CoreFoundation")
    end

    add_configs("tls", { description = "Enable TLS support.", default = (is_plat("macosx") and "securetransport" or "openssl"), values = { true, false, "openssl", "gnutls", "securetransport" } })
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
                package:add("deps", "openssl")
            end
        elseif tls then
            if tls == "openssl" then
                package:add("deps", "openssl")
            elseif tls == "securetransport" then
                package:add("frameworks", "Security")
            elseif tls == "gnutls" then
                package:add("deps", "gnutls")
            end
        end
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

        -- SecureTransport must be handled by system so we don't worry about providing CFLAGS and LDFLAGS
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
                print("Using SSL "..ssl:name().." from "..libssl.linkdir..", include dir: "..ssl_incdir)
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

        print("MFlags: ", mflags)
        print("MXXFlags: ", mxxflags)
        print("LDFlags: ", ldflags)
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
