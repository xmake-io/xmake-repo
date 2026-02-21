package("openssl3")
    set_homepage("https://www.openssl.org/")
    set_description("A robust, commercial-grade, and full-featured toolkit for TLS and SSL.")
    set_license("Apache-2.0")

    add_urls("https://github.com/openssl/openssl/archive/refs/tags/openssl-$(version).zip")

    add_versions("3.6.1", "b5fb172237ed3b1b47a9f7f15d3a40f9e9563f59f544b7078780ee27279a3c0f")
    add_versions("3.6.0", "273d989d1157f0bd494054e1b799b6bdba39d4acaff6dfcb8db02656f1b454dd")
    add_versions("3.5.5", "00d0b9dbe230bf7adac34e6da4557ca8874bf1411547f7e13d86bdb4342c04f8")
    add_versions("3.5.4", "6e6ca87952a3908282bae88c6e6a5d38bc6fc25d5570218866e5f2d206c03be1")
    add_versions("3.5.1", "9a1472b5e2a019f69da7527f381b873e3287348f3ad91783f83fff4e091ea4a8")
    add_versions("3.4.4", "df15282cfd91ff525bebe91783e7a1912cdd6303627a6ca7caf50ce449bc85bb")
    add_versions("3.4.2", "d313ac2ee07ad0d9c6e9203c56a485b3ecacac61c18fe450fe3c1d4db540ad71")
    add_versions("3.3.6", "9b604f79c0e7311ac97904d603d13c84425c35bfd83d73f9037c9cbf99bb262b")
    add_versions("3.3.4", "88c892a670df8924889f3bfd2f2dde822e1573a23dc4176556cb5170b40693ea")
    add_versions("3.3.2", "4cda357946f9dd5541b565dba35348d614288e88aeb499045018970c789c9d61")
    add_versions("3.3.1", "307284f39bfb7061229c57e263e707655aa80aa9950bf6def28ed63fec91a726")
    add_versions("3.2.5", "08a3fe150bd69a83ac64e222bdccf0698c493a94e161e4d080c82d1f308dc4e1")
    add_versions("3.1.8", "bbd5cbd8cc8ea852d31c001a9b767eadef0548b098e132b580a1f0c80d1778b7")
    add_versions("3.0.19", "82ff998847ee1346fefa7b6aa9402fbd0c81e971ad88793e44b21a39f2be1790")
    add_versions("3.0.17", "1129500758754ce4ff7eba7e46403dd56d5aa0a4e517a8fff7dac6fe120d0461")
    add_versions("3.0.14", "9590b9ae18c4de183be74dfc9da5be1f1e8f85dd631a78bc74c0ebc3d7e27a93")
    add_versions("3.0.7", "fcb37203c6bf7376cfd3aeb0be057937b7611e998b6c0d664abde928c8af3eb7")
    add_versions("3.0.6", "9b45be41df0d6e9cf9e340a64525177662f22808ac69aee6bfb29c511284dae4")
    add_versions("3.0.5", "4313c91fb0412e6a600493eb7c59bd555c4ff2ea7caa247a98c8456ad6f9fc74")
    add_versions("3.0.4", "5b690a5c00e639f3817e2ee15c23c36874a1f91fa8c3a83bda3276d3d6345b76")
    add_versions("3.0.3", "9bc56fd035f980cf74605264b04d84497df657c4f7ca68bfa77512e745f6c1a6")
    add_versions("3.0.2", "ce3cbb41411731852e52bf96c06f097405c81ebf60ba81e0b9ca05d41dc92681")
    add_versions("3.0.1", "53d8121af1c33c62a05a5370e9ba40fcc237717b79a7d99009b0c00c79bd7d78")
    add_versions("3.0.0", "1bdb33f131af75330de94475563c62d6908ac1c18586f7f4aa209b96b0bfc2f9")

    -- https://github.com/microsoft/vcpkg/blob/11faa3f168ec2a2f77510b92a42fb5c8a7e28bd8/ports/openssl/command-line-length.patch
    add_patches("3.3.2", path.join(os.scriptdir(), "patches", "3.3.2", "command-line-length.patch"), "e969153046f22d6abbdedce19191361f20edf3814b3ee47fb79a306967e03d81")
    -- https://github.com/openssl/openssl/issues/28745
    add_patches("3.6.0", path.join(os.scriptdir(), "patches", "3.6.0", "c20d4704e9e99a89d29f5ee848f9498694388905.patch"), "5d2523a6e0cc938c5d5acab849899da4b6a333b51151eaac5bd3b52741536bbc")

    on_fetch("fetch")

    -- https://security.stackexchange.com/questions/173425/how-do-i-calculate-md2-hash-with-openssl
    add_configs("md2", {description = "Enable MD2 on OpenSSl3 or not", default = false, type = "boolean"})
    add_configs("multi-threading", {description = "Enable multi-threading support.", default = true, type = "boolean"})

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
                package:add("deps", "nasm")
                -- the perl executable found in GitForWindows will fail to build OpenSSL
                -- see https://github.com/openssl/openssl/blob/master/NOTES-PERL.md#perl-on-windows
                package:add("deps", "strawberry-perl", {system = false})
                if package:config("jom") then
                    -- check xmake tool jom
                    import("package.tools.jom", {try = true})
                    if jom then
                        package:add("deps", "jom", {private = true})
                    end
                end
            elseif package:is_plat("android", "wasm") and is_subhost("windows") and os.arch() == "x64" then
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
            package:add("syslinks", "ws2_32", "user32", "crypt32", "advapi32")
        elseif package:is_plat("linux", "bsd", "cross") then
            package:add("syslinks", "dl")
            if (package:config("multi-threading")) then
                package:add("syslinks", "pthread")
            end
        end
        if package:is_plat("linux") then
            package:add("extsources", "apt::libssl-dev")
        end
    end)

    on_install("windows", function (package)
        import("package.tools.jom", {try = true})
        import("package.tools.nmake")
        local configs = {"Configure", "no-tests"}
        local target
        if package:is_arch("x86", "i386") then
            target = "VC-WIN32"
        elseif package:is_arch("arm64") then
            target = "VC-WIN64-ARM"
        elseif package:is_arch("arm.*") then
            target = "VC-WIN32-ARM"
        else
            target = "VC-WIN64A"
        end
        table.insert(configs, target)
        table.insert(configs, package:config("shared") and "shared" or "no-shared")
        table.insert(configs, "--prefix=" .. package:installdir())
        table.insert(configs, "--openssldir=" .. package:installdir())

        if package:config("md2") then
            table.insert(configs, "enable-md2")
        end
        table.insert(configs, package:config("multi-threading") and "threads" or "no-threads")

        if package:config("jom") and jom then
            table.insert(configs, "no-makedepend")
        end

        if package:is_debug() then
            table.insert(configs, "/FS")
        else
            io.replace("Configurations/10-main.conf", "/debug", "", {plain = true})
            io.replace("Configurations/10-main.conf", "/Zi", "", {plain = true})
            io.replace("Configurations/50-masm.conf", "/Zi", "", {plain = true})
            if package:version():gt("3.0.17") then
                io.replace("Configurations/50-win-clang-cl.conf", "/Zi", "", {plain = true})
            end
            io.replace("util/copy.pl", "if (-d $dest)", "if (! -e $_) { next; }\n\tif (-d $dest)", {plain = true})
        end

        os.vrunv("perl", configs)

        if package:config("jom") and jom then
            jom.build(package)
            jom.make(package, {"install_sw"})
        else
            nmake.build(package)
            nmake.make(package, {"install_sw"})
        end
    end)

    on_install("mingw", "msys", function (package)
        local configs = {"Configure", "--libdir=lib", "no-tests"}
        table.insert(configs, package:is_arch("i386", "x86") and "mingw" or "mingw64")
        table.insert(configs, package:config("shared") and "shared" or "no-shared")
        local installdir = package:installdir()
        -- Use MSYS2 paths instead of Windows paths
        if is_subhost("msys") then
            installdir = installdir:gsub("(%a):[/\\](.+)", "/%1/%2"):gsub("\\", "/")
        end
        table.insert(configs, "--prefix=" .. installdir)
        table.insert(configs, "--openssldir=" .. installdir)

        if package:config("md2") then
            table.insert(configs, "enable-md2")
        end
        table.insert(configs, package:config("multi-threading") and "threads" or "no-threads")

        local buildenvs = import("package.tools.autoconf").buildenvs(package)
        buildenvs.RC = package:build_getenv("mrc")
        if is_subhost("msys") then
            local rc = buildenvs.RC
            if rc then
                rc = rc:gsub("(%a):[/\\](.+)", "/%1/%2"):gsub("\\", "/")
                buildenvs.RC = rc
            end
        end
        -- fix 'cp: directory fuzz does not exist'
        if package:config("shared") then
            os.mkdir("fuzz")
        end
        os.vrunv("perl", configs, {envs = buildenvs})
        import("package.tools.make").build(package)
        import("package.tools.make").make(package, {"install_sw"})
    end)

    on_install("linux", "macosx", "bsd", function (package)
        -- https://wiki.openssl.org/index.php/Compilation_and_Installation#PREFIX_and_OPENSSLDIR
        local buildenvs = import("package.tools.autoconf").buildenvs(package)
        local configs = {"--openssldir=" .. package:installdir(),
                         "--libdir=lib",
                         "--prefix=" .. package:installdir()}
        table.insert(configs, package:config("shared") and "shared" or "no-shared")
        if package:debug() then
            table.insert(configs, "--debug")
        end

        if package:config("md2") then
            table.insert(configs, "enable-md2")
        end
        table.insert(configs, package:config("multi-threading") and "threads" or "no-threads")

        os.vrunv("./config", configs, {envs = buildenvs})
        local makeconfigs = {CFLAGS = buildenvs.CFLAGS, ASFLAGS = buildenvs.ASFLAGS}
        import("package.tools.make").build(package, makeconfigs)
        import("package.tools.make").make(package, {"install_sw"})
        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"), "*.a"))
        end
    end)

    on_install("cross", "android", "iphoneos", "wasm", function (package)
        local target_arch = "generic32"
        if package:is_arch("x86_64") then
            target_arch = "x86_64"
        elseif package:is_arch("i386", "x86") then
            target_arch = "x86"
        elseif package:is_arch("arm64", "arm64-v8a") then
            target_arch = "aarch64"
        elseif package:is_arch("arm.*") then
            target_arch = "armv4"
        elseif package:is_arch(".*64") then
            target_arch = "generic64"
        end

        local target_plat = "linux"
        if package:is_plat("macosx") then
            target_plat = "darwin64"
            target_arch = "x86_64-cc"
        elseif package:is_plat("iphoneos") then
            local xcode = package:toolchain("xcode")
            local simulator = xcode and xcode:config("appledev") == "simulator"
            if simulator then
                target_plat = "iossimulator"
                target_arch = "xcrun"
            else
                if package:is_arch("arm64", "x86_64") then
                    target_plat = "ios64"
                else
                    target_plat = "ios"
                end
                target_arch = "cross"
            end
        end

        local target = target_plat .. "-" .. target_arch
        local configs = {target,
                         package:config("shared") and "shared" or "no-shared",
                         "--libdir=lib",
                         "--openssldir=" .. package:installdir():gsub("\\", "/"),
                         "--prefix=" .. package:installdir():gsub("\\", "/")}

        if package:config("md2") then
            table.insert(configs, "enable-md2")
        end
        table.insert(configs, package:config("multi-threading") and "threads" or "no-threads")

        if package:is_plat("wasm") then
            -- @see https://github.com/openssl/openssl/issues/12174
            table.insert(configs, "no-afalgeng")
        end

        local buildenvs = import("package.tools.autoconf").buildenvs(package)
        if (package:is_cross() and package:is_plat("android") and is_subhost("windows")) or
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
        local makeconfigs = {CFLAGS = buildenvs.CFLAGS, ASFLAGS = buildenvs.ASFLAGS}
        import("package.tools.make").build(package, makeconfigs)
        import("package.tools.make").make(package, {"install_sw"})
        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"), "*.a"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SSL_new", {includes = "openssl/ssl.h"}))
    end)
