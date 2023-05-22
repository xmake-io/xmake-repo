package("openssl")

    set_homepage("https://www.openssl.org/")
    set_description("A robust, commercial-grade, and full-featured toolkit for TLS and SSL.")

    add_urls("https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_$(version).zip", {version = function (version)
        return version:gsub("^(%d+)%.(%d+)%.(%d+)-?(%a*)$", "%1_%2_%3%4")
    end, excludes = "*/fuzz/*"})
    add_versions("1.1.1-t", "9422774f3ce0f9cb4db5d862efbf43b4fcc096b37b4ac7157e7c5172113a8a22")
    add_patches("1.1.1-t", path.join(os.scriptdir(), "patches", "1.1.1t.diff"), "8009edde46e5577213212ec68f8a40451ceb514fddd892240b1465213b7d2d11")
    add_versions("1.1.1-s", "aa76dc0488bc67f5c964d085e37a0f5f452e45c68967816a336fa00f537f5cc5")
    add_versions("1.1.1-r", "20af2fac5dff04e71c2f2d6729ee84befbea741e3aaeba18a1a541e04f3f1997")
    add_versions("1.1.1-q", "df86e6adcff1c91a85cef139dd061ea40b7e49005e8be16522cf4864bfcf5eb8")
    add_patches("1.1.1-q", path.join(os.scriptdir(), "patches", "1.1.1q.diff"), "cfe6929f9db2719e695be0b61f8c38fe8132544c5c58ca8d07383bfa6c675b7b")
    add_versions("1.1.1-p", "7fe975ffe91d8343ebd021059eeea3c6b1d236c3826b3a08ef59fcbe75069f5b")
    add_patches("1.1.1-p", path.join(os.scriptdir(), "patches", "1.1.1p.diff"), "f102fed5867e143ae3ace1febd0b2725358c614c86328e68022f1ea21491b42c")
    add_versions("1.1.1-o", "1cd761790cf576e7f45c17798c47064f0f6756d4fcdbc1e657b0a4d9c60f3a52")
    add_versions("1.1.1-n", "614d69141fd622bc3db2adf7c824eaa19c7e532937b2cd7144b850d692f9f150")
    add_versions("1.1.1-m", "dab2287910427d82674618d512ba2571401539ca6ed12ab3c3143a0db9fad542")
    add_versions("1.1.1-l", "23d8908e82b63af754018256a4eb02f13965f10067969f6a63f497960c11dbeb")
    add_versions("1.1.1-k", "255c038f5861616f67b527434475d226f5fe00522fbd21fafd3df32019edd202")
    add_versions("1.1.1-h", "0a976b769bdb26470971a184f5263d0c3256152d5671ed7287cf17acc4698afc")
    add_versions("1.1.0-l", "a305d4af4b442ad61ba3d7e82905d09bfbd80424e132e10df4899d064aa47ce2")
    add_versions("1.0.2-u", "493f8b34574d0cf8598adbdec33c84b8a06f0617787c3710d20827c01291c09c")
    add_versions("1.0.0",  "9b67e5ad1a4234c1170ada75b66321e914da4f3ebaeaef6b28400173aaa6b378")

    on_fetch("fetch")

    on_load(function (package)
        if package:is_plat("windows") and (not package.is_built or package:is_built()) then
            package:add("deps", "nasm")
            -- the perl executable found in GitForWindows will fail to build OpenSSL
            -- see https://github.com/openssl/openssl/blob/master/NOTES-PERL.md#perl-on-windows
            package:add("deps", "strawberry-perl", { system = false })
        end

        -- @note we must use package:is_plat() instead of is_plat in description for supporting add_deps("openssl", {host = true}) in python
        if package:is_plat("windows") then
            package:add("links", "libssl", "libcrypto")
        else
            package:add("links", "ssl", "crypto")
        end
        if package:is_plat("windows", "mingw") then
            package:add("syslinks", "ws2_32", "user32", "crypt32", "advapi32")
        elseif package:is_plat("linux", "cross") then
            package:add("syslinks", "pthread", "dl")
        end
        if package:is_plat("linux") then
            package:add("extsources", "apt::libssl-dev")
        end
    end)

    on_install("windows", function (package)
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
        os.vrunv("perl", configs)
        import("package.tools.nmake").install(package)
    end)

    on_install("mingw", function (package)
        local configs = {"Configure", "no-tests"}
        table.insert(configs, package:is_arch("i386", "x86") and "mingw" or "mingw64")
        table.insert(configs, package:config("shared") and "shared" or "no-shared")
        local installdir = package:installdir()
        -- Use MSYS2 paths instead of Windows paths
        if is_subhost("msys") then
            installdir = installdir:gsub("(%a):[/\\](.+)", "/%1/%2"):gsub("\\", "/")
        end
        table.insert(configs, "--prefix=" .. installdir)
        table.insert(configs, "--openssldir=" .. installdir)
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
                         "--prefix=" .. package:installdir()}
        table.insert(configs, package:config("shared") and "shared" or "no-shared")
        if package:debug() then
            table.insert(configs, "--debug")
        end
        os.vrunv("./config", configs, {envs = buildenvs})
        import("package.tools.make").build(package)
        import("package.tools.make").make(package, {"install_sw"})
        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"), "*.a"))
        end
    end)

    on_install("cross", "android", function (package)

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
        end

        local target = target_plat .. "-" .. target_arch
        local configs = {target,
                         "-DOPENSSL_NO_HEARTBEATS",
                         "no-shared",
                         "no-threads",
                         "--openssldir=" .. package:installdir(),
                         "--prefix=" .. package:installdir()}
        local buildenvs = import("package.tools.autoconf").buildenvs(package)
        os.vrunv("./Configure", configs, {envs = buildenvs})
        import("package.tools.make").build(package)
        import("package.tools.make").make(package, {"install_sw"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SSL_new", {includes = "openssl/ssl.h"}))
    end)
