package("libssh2")

    set_homepage("https://www.libssh2.org/")
    set_description("C library implementing the SSH2 protocol")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/libssh2/libssh2/releases/download/libssh2-$(version)/libssh2-$(version).tar.gz",
             "https://www.libssh2.org/download/libssh2-$(version).tar.gz",
             "https://github.com/libssh2/libssh2.git")
    add_versions("1.10.0", "2d64e90f3ded394b91d3a2e774ca203a4179f69aebee03003e5a6fa621e41d51")

    add_deps("libgcrypt")
    if is_plat("linux") then
        add_deps("openssl")
    end

    on_load(function (package)
        if package:gitref() then
            package:add("deps", "automake", "autoconf")
        end
    end)

    on_install("macosx", "linux", function (package)
        local configs = {
        "--disable-silent-rules",
        "--disable-examples-build",
        "--with-openssl",
        "--with-libz"}
        local openssl = package:dep("openssl")
        if openssl then
            table.insert(configs, "--with-libssl-prefix=" .. openssl:installdir())
        end
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_plat("linux") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        if package:gitref() then
            os.vrunv("sh", {"./buildconf"})
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libssh2_exit", {includes = "libssh2.h"}))
    end)
