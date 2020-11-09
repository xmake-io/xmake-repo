package("openssl")

    set_homepage("https://www.openssl.org/")
    set_description("A robust, commercial-grade, and full-featured toolkit for TLS and SSL.")

    add_urls("https://www.openssl.org/source/openssl-$(version).tar.gz",
            {alias = "home", version = function (version)
                local patch = version:match("%+%d+")
                if patch then
                    version = version:gsub("%+%d+", string.char(string.byte("a") + tonumber(patch)))
                end
                return version
            end, excludes = "*/fuzz/*"})
    add_urls("https://github.com/openssl/openssl/archive/OpenSSL_$(version).zip",
            {alias = "github", version = function (version)
                local patch = version:match("%+%d+")
                if patch then
                    version = version:gsub("%+%d+", string.char(string.byte("a") + tonumber(patch)))
                end
                return version:gsub("%.", "_")
            end, excludes = "*/fuzz/*"})

    add_versions("home:1.1.1+7", "5c9ca8774bd7b03e5784f26ae9e9e6d749c9da2438545077e6b3d755a06595d9")
    add_versions("home:1.1.0+11", "74a2f756c64fd7386a29184dc0344f4831192d61dc2481a93a4c5dd727f41148")
    add_versions("home:1.0.2+20", "ecd0c6ffb493dd06707d38b14bb4d8c2288bb7033735606569d8f90f89669d16")
    add_versions("home:1.0.0", "1bbf9afc5a6215121ac094147d0a84178294fe4c3d0a231731038fd3717ba7ca")
    add_versions("github:1.1.1+7", "0a976b769bdb26470971a184f5263d0c3256152d5671ed7287cf17acc4698afc")
    add_versions("github:1.1.0+11", "a305d4af4b442ad61ba3d7e82905d09bfbd80424e132e10df4899d064aa47ce2")
    add_versions("github:1.0.2+20", "493f8b34574d0cf8598adbdec33c84b8a06f0617787c3710d20827c01291c09c")
    add_versions("github:1.0.0", "9b67e5ad1a4234c1170ada75b66321e914da4f3ebaeaef6b28400173aaa6b378")

    add_links("ssl", "crypto")

    on_install("linux", "macosx", function (package)
        os.vrun("./config %s --prefix=\"%s\"", package:debug() and "--debug" or "", package:installdir())
        import("package.tools.make").install(package)
    end)

    on_install("cross", function (package)
        local target = "linux-generic32"
        if package:is_os("linux") then
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
