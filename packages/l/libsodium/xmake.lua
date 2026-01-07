package("libsodium")
    set_homepage("https://libsodium.org")
    set_description("Sodium is a new, easy-to-use software library for encryption, decryption, signatures, password hashing and more.")
    set_license("ISC")

    set_urls("https://download.libsodium.org/libsodium/releases/libsodium-$(version).tar.gz",
             "https://github.com/jedisct1/libsodium/releases/download/$(version)-RELEASE/libsodium-$(version).tar.gz",
             "https://github.com/jedisct1/libsodium.git")

    add_versions("1.0.21", "9e4285c7a419e82dedb0be63a72eea357d6943bc3e28e6735bf600dd4883feaf")
    add_versions("1.0.20", "ebb65ef6ca439333c2bb41a0c1990587288da07f6c7fd07cb3a18cc18d30ce19")
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
            local configs = {}
            if package:debug() then
                table.insert(configs, "--enable-debug")
            end
            if package:config("shared") then
                table.insert(configs, "--enable-static=no")
                table.insert(configs, "--enable-shared=yes")
            else
                table.insert(configs, "--enable-static=yes")
                table.insert(configs, "--enable-shared=no")
            end
            local cflags = {}
            if package:is_plat("linux") and package:is_arch("arm64") then
                table.insert(cflags, "-flax-vector-conversions")
            end
            import("package.tools.autoconf").install(package, configs, { cflags = cflags })
        else
            os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
            import("package.tools.xmake").install(package)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sodium_init", {includes = "sodium.h"}))
    end)
