package("openssl3")

    set_homepage("https://www.openssl.org/")
    set_description("A robust, commercial-grade, and full-featured toolkit for TLS and SSL.")

    add_urls("https://github.com/openssl/openssl/archive/refs/tags/openssl-$(version).zip")
    add_versions("3.0.7", "fcb37203c6bf7376cfd3aeb0be057937b7611e998b6c0d664abde928c8af3eb7")
    add_versions("3.0.6", "9b45be41df0d6e9cf9e340a64525177662f22808ac69aee6bfb29c511284dae4")
    add_versions("3.0.5", "4313c91fb0412e6a600493eb7c59bd555c4ff2ea7caa247a98c8456ad6f9fc74")
    add_versions("3.0.4", "5b690a5c00e639f3817e2ee15c23c36874a1f91fa8c3a83bda3276d3d6345b76")
    add_versions("3.0.3", "9bc56fd035f980cf74605264b04d84497df657c4f7ca68bfa77512e745f6c1a6")
    add_versions("3.0.2", "ce3cbb41411731852e52bf96c06f097405c81ebf60ba81e0b9ca05d41dc92681")
    add_versions("3.0.1", "53d8121af1c33c62a05a5370e9ba40fcc237717b79a7d99009b0c00c79bd7d78")
    add_versions("3.0.0", "1bdb33f131af75330de94475563c62d6908ac1c18586f7f4aa209b96b0bfc2f9")

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
        if package:is_plat("linux", "mingw", "bsd") and package:is_arch("x86_64") then
            package:add("linkdirs", "lib64")
        end
        if package:is_plat("linux") then
            package:add("extsources", "apt::libssl-dev")
        end
    end)

    on_install("windows", function (package)
        local configs = {"Configure"}
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
        local makeconfigs = {CFLAGS = buildenvs.CFLAGS, ASFLAGS = buildenvs.ASFLAGS}
        import("package.tools.make").build(package, makeconfigs)
        import("package.tools.make").make(package, {"install_sw"})
        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"), "*.a"), path.join(package:installdir("lib64"), "*.a"))
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
        local makeconfigs = {CFLAGS = buildenvs.CFLAGS, ASFLAGS = buildenvs.ASFLAGS}
        import("package.tools.make").build(package, makeconfigs)
        import("package.tools.make").make(package, {"install_sw"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SSL_new", {includes = "openssl/ssl.h"}))
    end)

