package("openssl4")
    set_homepage("https://www.openssl.org/")
    set_description("A robust, commercial-grade, and full-featured toolkit for TLS and SSL.")
    set_license("Apache-2.0")

    add_urls("https://github.com/openssl/openssl/archive/refs/tags/openssl-$(version).zip")

    add_versions("4.0.3", "e24c35ad40ce1affe615c3c41f0e1e3054435f554578579f7f5a9fe1cb166685")

    -- https://security.stackexchange.com/questions/173425/how-do-i-calculate-md2-hash-with-openssl
    add_configs("md2", {description = "Enable MD2 support.", default = false, type = "boolean"})
    add_configs("multi-threading", {description = "Enable multi-threading support.", default = true, type = "boolean"})
    -- The provider and fipsmodule.cnf are installed, but activation remains an application configuration choice.
    add_configs("fips", {description = "Build the FIPS provider (not a FIPS certification).", default = not is_plat("wasm"), type = "boolean"})
    add_configs("openssldir", {description = "OpenSSL configuration directory (defaults to <prefix>/ssl).", type = "string"})
    add_configs("target", {description = "Override the built-in OpenSSL Configure target.", type = "string"})
    add_configs("extra_build_opts", {description = "Additional comma-separated OpenSSL Configure options.", type = "string"})

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    -- @see https://github.com/xmake-io/xmake-repo/pull/7797#issuecomment-3153471643
    if is_plat("windows") then
        add_configs("jom", {description = "Try using jom to compile in parallel.", default = true, type = "boolean"})
    end

    on_load(function (package)
        if not package:is_precompiled() then
            if package:is_plat("windows") then
                if package:is_arch("x86", "i386", "x64", "x86_64") then
                    package:add("deps", "nasm", {private = true})
                end
                -- the perl executable found in GitForWindows will fail to build OpenSSL
                -- see https://github.com/openssl/openssl/blob/master/NOTES-PERL.md#perl-on-windows
                package:add("deps", "strawberry-perl", {system = false, private = true})
                if package:config("jom") then
                    -- check xmake tool jom
                    import("package.tools.jom", {try = true})
                    if jom then
                        package:add("deps", "jom", {private = true})
                    end
                end
            elseif package:is_plat("android", "wasm") and is_host("windows") and os.arch() == "x64" then
                -- when building for android on windows, use msys2 perl instead of strawberry-perl to avoid configure issue
                package:add("deps", "msys2", {configs = {msystem = "MINGW64", base_devel = true}, private = true})
            end
        end

        -- @note we must use package:is_plat() instead of is_plat in description for supporting add_deps("openssl", {host = true}) in python
        if package:is_plat("windows") then
            package:add("links", "libssl", "libcrypto")
        else
            package:add("links", "ssl", "crypto")
        end
        if package:is_plat("windows", "mingw", "msys") then
            package:add("syslinks", "ws2_32", "user32", "crypt32", "advapi32", "bcrypt")
        elseif package:is_plat("linux", "bsd", "cross") then
            package:add("syslinks", "dl")
            if package:config("multi-threading") then
                package:add("syslinks", "pthread")
            end
        end
        if package:is_plat("linux") then
            package:add("syslinks", "rt")
        end
        package:addenv("PATH", "bin")
        package:addenv("OPENSSL_MODULES", "lib/ossl-modules")
    end)

    on_install("windows", function (package)
        import("package.tools.jom", {try = true})
        import("package.tools.nmake")
        local configs = table.join("Configure", import("configure.configs")(package))
        local target
        if package:is_arch("x86", "i386") then
            target = "VC-WIN32"
        elseif package:is_arch("arm64") then
            target = package:has_tool("cc", "clang_cl") and "VC-CLANG-WIN64-CLANGASM-ARM" or "VC-WIN64-CLANGASM-ARM"
        elseif package:is_arch("arm.*") then
            target = "VC-WIN32-ARM"
        else
            target = "VC-WIN64A"
        end
        table.insert(configs, package:config("target") or target)

        if package:config("jom") and jom then
            table.insert(configs, "no-makedepend")
        end

        table.insert(configs, "/FS")
        if not package:is_debug() then
            import("configure.patchPDB")(package)
        end

        os.vrunv("perl", configs)

        if package:config("jom") and jom then
            jom.build(package)
            jom.make(package, {"install", "/J1"})
        else
            nmake.build(package)
            nmake.make(package, {"install"})
        end
        os.tryrm(package:installdir("lib", "*.pdb"))
    end)

    on_install("mingw", "msys", function (package)
        local target
        if package:is_arch("arm64", "aarch64") then
            target = "mingwarm64"
        else
            target = package:is_arch("i386", "x86") and "mingw" or "mingw64"
        end
        local configs = table.join("Configure", package:config("target") or target, import("configure.configs")(package))

        local buildenvs = import("package.tools.autoconf").buildenvs(package)
        buildenvs.CFLAGS = (package:is_debug() and "-O0 -g" or "-O3") .. " " .. (buildenvs.CFLAGS or "")
        buildenvs.RC = package:build_getenv("mrc")
        if is_subhost("msys") then
            local rc = buildenvs.RC
            if rc then
                rc = rc:gsub("(%a):[/\\](.+)", "/%1/%2"):gsub("\\", "/")
                buildenvs.RC = rc
            end
        end
        os.vrunv("perl", configs, {envs = buildenvs})
        import("package.tools.make").build(package, {}, {envs = buildenvs})
        import("package.tools.make").make(package, {"install", "-j1"}, {envs = buildenvs})
    end)

    on_install("macosx", "bsd", "linux", "cross", "android", "iphoneos", "wasm", "harmony", function (package)
        local target_arch = "generic32"
        if package:is_arch("x86_64") then
            target_arch = "x86_64"
        elseif package:is_arch("i386", "x86") then
            target_arch = "x86"
        elseif package:is_arch("arm64", "arm64-v8a", "aarch64") then
            target_arch = "aarch64"
        elseif package:is_arch("arm.*") then
            target_arch = "armv4"
        elseif package:is_arch(".*64") then
            target_arch = "generic64"
        end

        local target_plat = "linux"
        if package:is_plat("macosx") then
            target_plat = "darwin64"
            target_arch = package:is_arch("arm64", "aarch64") and "arm64-cc" or "x86_64-cc"
        elseif package:is_plat("bsd") then
            target_plat = "BSD"
        elseif package:is_plat("harmony") then
            target_plat = "ohos"
            if package:is_arch("arm64", "arm64-v8a") then
                target_arch = "aarch64"
            elseif package:is_arch("arm.*") then
                target_arch = "arm"
            end
        elseif package:is_plat("iphoneos") then
            local xcode = package:toolchain("xcode")
            local simulator = xcode and xcode:config("appledev") == "simulator"
            if simulator then
                target_plat = "iossimulator"
                target_arch = package:arch() .. "-xcrun"
            else
                if package:is_arch("arm64", "x86_64") then
                    target_plat = "ios64"
                else
                    target_plat = "ios"
                end
                target_arch = "xcrun"
            end
        end

        local target = package:config("target") or (target_plat .. "-" .. target_arch)
        local configs = table.join(target, import("configure.configs")(package))

        import("configure.patch")(package)
        local buildenvs = import("package.tools.autoconf").buildenvs(package)
        -- CFLAGS from the toolchain replace OpenSSL's defaults, including optimization and debug symbols.
        buildenvs.CFLAGS = (package:is_debug() and "-O0 -g" or "-O3") .. " " .. (buildenvs.CFLAGS or "")
        if package:is_plat("macosx", "iphoneos") and package:config("shared") then
            buildenvs.LDFLAGS = (buildenvs.LDFLAGS or "") .. " -Wl,-headerpad_max_install_names"
        end
        if (package:is_plat("android") and is_host("windows")) or
            package:is_plat("wasm") then

            buildenvs.CFLAGS = buildenvs.CFLAGS:gsub("\\", "/")
            buildenvs.CXXFLAGS = buildenvs.CXXFLAGS:gsub("\\", "/")
            buildenvs.CPPFLAGS = buildenvs.CPPFLAGS:gsub("\\", "/")
            buildenvs.ASFLAGS = buildenvs.ASFLAGS:gsub("\\", "/")
            os.vrunv("perl", table.join("./Configure", configs), {envs = buildenvs})
        else
            os.vrunv("./Configure", configs, {envs = buildenvs})
        end

        if is_host("windows") and package:is_plat("wasm") then
            io.replace("Makefile", "bat.exe", "bat", {plain = true})
        end
        import("package.tools.make").build(package, {}, {envs = buildenvs})
        import("package.tools.make").make(package, {"install", "-j1"}, {envs = buildenvs})
        if package:config("shared") then
            os.tryrm(package:installdir("lib", "*.a"))
        end
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <openssl/ssl.h>
            #if OPENSSL_VERSION_MAJOR != 4
            #error Expected OpenSSL 4
            #endif
            void test(void) {
                SSL_CTX *ctx = SSL_CTX_new(TLS_method());
                SSL *ssl = SSL_new(ctx);
                SSL_free(ssl);
                SSL_CTX_free(ctx);
            }
        ]]}))
    end)
