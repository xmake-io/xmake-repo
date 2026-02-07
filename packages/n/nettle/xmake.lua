package("nettle")
    set_homepage("https://www.lysator.liu.se/~nisse/nettle/")
    set_description("Nettle is a cryptographic library that is designed to fit easily in more or less any context.")
    set_license("LGPL-3.0")

    add_urls("https://ftpmirror.gnu.org/gnu/nettle/nettle-$(version).tar.gz",
             "https://ftp.gnu.org/gnu/nettle/nettle-$(version).tar.gz")
    add_versions("3.6", "d24c0d0f2abffbc8f4f34dcf114b0f131ec3774895f3555922fe2f40f3d5e3f1")
    add_versions("3.9.1", "ccfeff981b0ca71bbd6fbcb054f407c60ffb644389a5be80d6716d5b550c6ce3")
    add_versions("3.10.1", "b0fcdd7fc0cdea6e80dcf1dd85ba794af0d5b4a57e26397eee3bc193272d9132")
    add_versions("4.0", "3addbc00da01846b232fb3bc453538ea5468da43033f21bb345cb1e9073f5094")

    add_deps("m4")
    add_deps("gmp")
    if is_plat("linux") then
        add_extsources("apt::nettle-dev")
    end

    on_install("@!windows and !wasm", function (package)
        if package:is_plat("iphoneos") then
            io.replace("configure", "#define gid_t int", "")
            io.replace("configure", "#define uid_t int", "")
        end
        local configs = {"--disable-openssl", "--disable-documentation", "--enable-pic"}
        if package:config("shared") then
            table.insert(configs, "--enable-shared")
            table.insert(configs, "--disable-static")
        else
            table.insert(configs, "--disable-shared")
            table.insert(configs, "--enable-static")
        end
        import("package.tools.autoconf")
        local envs = autoconf.buildenvs(package, {packagedeps = {"gmp"}})
        autoconf.install(package, configs, {envs = envs})
        if os.isfile(package:installdir("lib64", "pkgconfig", "nettle.pc")) then
            package:add("linkdirs", "lib64")
        end
    end)

    on_test(function (package)
        assert(package:check_csnippets([[
            void sha1_test(void) {
                struct sha1_ctx ctx;
                sha1_init(&ctx);
                uint8_t const buffer[] = "test";
                sha1_update(&ctx, sizeof(buffer), buffer);
                uint8_t digest[SHA1_DIGEST_SIZE];
                sha1_digest(&ctx, SHA1_DIGEST_SIZE, digest);
            }
        ]], {includes = "nettle/sha1.h"}))
        assert(package:check_csnippets([[
            void rsa_test(void) {
                struct rsa_public_key pub;
                rsa_public_key_init(&pub);
                rsa_public_key_clear(&pub);
            }
        ]], {includes = "nettle/rsa.h"}))
    end)
