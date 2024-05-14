package("libsodium")
    set_homepage("https://libsodium.org")
    set_description("Sodium is a new, easy-to-use software library for encryption, decryption, signatures, password hashing and more.")
    set_license("ISC")

    set_urls("https://download.libsodium.org/libsodium/releases/libsodium-$(version).tar.gz",
             "https://github.com/jedisct1/libsodium/releases/download/$(version)-RELEASE/libsodium-$(version).tar.gz",
             "https://github.com/jedisct1/libsodium.git")

    add_versions("1.0.19", "018d79fe0a045cca07331d37bd0cb57b2e838c51bc48fd837a1472e50068bbea")
    add_versions("1.0.18", "6f504490b342a4f8a4c4a02fc9b866cbef8622d5df4e5452b46be121e46636c1")

    if is_plat("linux", "macosx") then
        add_deps("autoconf", "automake", "libtool", "pkg-config")
    end

    on_install(function (package)
        if not package:config("shared") then
            package:add("defines", "SODIUM_STATIC")
        end

        if package:is_plat("linux", "macosx") then
            import("package.tools.autoconf").install(package)
        else
            os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
            import("package.tools.xmake").install(package)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sodium_init", {includes = "sodium.h"}))
    end)
