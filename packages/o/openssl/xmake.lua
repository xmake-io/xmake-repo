package("openssl")

    set_homepage("https://www.openssl.org/")
    set_description("A robust, commercial-grade, and full-featured toolkit for TLS and SSL.")

    add_urls("https://www.openssl.org/source/openssl-$(version).tar.gz", {alias = "home", excludes = "*/fuzz/*"})
    add_urls("https://github.com/openssl/openssl/archive/OpenSSL_$(version).zip",
             {alias = "github", version = function (version) return version:gsub("%.", "_") end, excludes = "*/fuzz/*"})
    add_versions("home:1.1.1k", "892a0875b9872acd04a9fde79b1f943075d5ea162415de3047c327df33fbaee5")
    add_versions("home:1.1.1h", "5c9ca8774bd7b03e5784f26ae9e9e6d749c9da2438545077e6b3d755a06595d9")
    add_versions("home:1.1.0l", "74a2f756c64fd7386a29184dc0344f4831192d61dc2481a93a4c5dd727f41148")
    add_versions("home:1.0.2u", "ecd0c6ffb493dd06707d38b14bb4d8c2288bb7033735606569d8f90f89669d16")
    add_versions("home:1.0.0", "1bbf9afc5a6215121ac094147d0a84178294fe4c3d0a231731038fd3717ba7ca")
    add_versions("github:1.1.1k", "255c038f5861616f67b527434475d226f5fe00522fbd21fafd3df32019edd202")
    add_versions("github:1.1.1h", "0a976b769bdb26470971a184f5263d0c3256152d5671ed7287cf17acc4698afc")
    add_versions("github:1.1.0l", "a305d4af4b442ad61ba3d7e82905d09bfbd80424e132e10df4899d064aa47ce2")
    add_versions("github:1.0.2u", "493f8b34574d0cf8598adbdec33c84b8a06f0617787c3710d20827c01291c09c")
    add_versions("github:1.0.0", "9b67e5ad1a4234c1170ada75b66321e914da4f3ebaeaef6b28400173aaa6b378")

    if is_plat("windows") then
        add_deps("strawberry-perl", "nasm")
        add_links("libssl", "libcrypto")
    else
        add_links("ssl", "crypto")
    end
    if is_plat("linux", "cross") then
        add_syslinks("dl")
    end

    on_fetch("fetch")

    on_install("windows", function (package)
        local args = {"Configure"}
        table.insert(args, (package:is_arch("x86") and "VC-WIN32" or "VC-WIN64A"))
        table.insert(args, "--prefix=" .. package:installdir())
        table.insert(args, "--openssldir=" .. package:installdir())
        os.vrunv("perl", args)

        -- temporary workaround, will be removed in future
        if xmake.version():ge("2.5.3") then
            import("package.tools.nmake").install(package)
        else
            local envs = import("core.tool.toolchain").load("msvc"):runenvs()
            envs.PATH = package:dep("nasm"):installdir("bin") .. path.envsep() .. envs.PATH
            import("package.tools.nmake").install(package, {}, {envs = envs})
        end
    end)

    on_install("linux", "macosx", function (package)
        -- https://wiki.openssl.org/index.php/Compilation_and_Installation#PREFIX_and_OPENSSLDIR
        os.vrun("./config %s --openssldir=\"%s\" --prefix=\"%s\"", package:debug() and "--debug" or "", package:installdir(), package:installdir())
        import("package.tools.make").install(package)
    end)

    on_install("cross", "android", function (package)
        local target = "linux-generic32"
        if package:is_targetos("linux") then
            if package:is_arch("arm64") then
                target = "linux-aarch64"
            else
                target = "linux-armv4"
            end
        end
        local configs = {target, "-DOPENSSL_NO_HEARTBEATS", "no-shared", "no-threads", "--prefix=" .. package:installdir()}
        local buildenvs = import("package.tools.autoconf").buildenvs(package)
        os.vrunv("./Configure", configs, {envs = buildenvs})
        local makeconfigs = {CFLAGS = buildenvs.CFLAGS, ASFLAGS = buildenvs.ASFLAGS}
        import("package.tools.make").install(package, makeconfigs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SSL_new", {includes = "openssl/ssl.h"}))
    end)
