package("leancrypto")
    set_homepage("https://leancrypto.org")
    set_description("Lean cryptographic library usable for bare-metal environments")

    add_urls("https://github.com/smuellerDD/leancrypto/archive/refs/tags/$(version).tar.gz",
             "https://github.com/smuellerDD/leancrypto.git")

    add_versions("v1.6.0", "b5057cfb990108c4a9f21832f1f35f3d98115012d1628e00650558e6b49e8285")
    add_versions("v1.5.1", "9c14639ea047554598a99d6a8cf2598b3cd89be0608df8cc06d80dd66087e2da")
    add_versions("v1.4.0", "32c52c3860cbdefddd3be01ff59f8f2a3d1d8556b9b9b152e190ff2290b7ea6f")
    add_versions("v1.3.0", "53b51936d77304e82cc6aa34a0a65eec3327ca1165342180694c5aa6a7d745c8")
    add_versions("v1.2.0", "247481cac4cedbf4b9e1c689b7726592015352a11cd22625013185d01cda2c15")

    if is_plat("linux") then
        add_extsources("pacman::leancrypto")
    end

    add_deps("meson", "ninja")

    on_install("linux", "cross", "mingw", "macosx", function (package)
        io.replace("meson.build", "cc.has_argument('-flto')", "false", {plain = true})
        io.replace("meson.build", "cc.has_argument('-ffat-lto-objects')", "false", {plain = true})
        local configs = {}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test(void) {
                static const uint8_t msg_256[] = {0x06, 0x3A, 0x53};
                uint8_t act[LC_SHA256_SIZE_DIGEST];
                LC_SHA256_CTX_ON_STACK(sha256_stack);
                lc_hash_init(sha256_stack);
                lc_hash_update(sha256_stack, msg_256, sizeof(msg_256));
                lc_hash_final(sha256_stack, act);
                lc_hash_zero(sha256_stack);
            }
        ]]}, {includes = "leancrypto/lc_sha256.h"}))
    end)
