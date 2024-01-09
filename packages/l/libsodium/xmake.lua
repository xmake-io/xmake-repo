package("libsodium")

    set_homepage("https://libsodium.org")
    set_description("Sodium is a new, easy-to-use software library for encryption, decryption, signatures, password hashing and more.")

    if is_plat("windows") then
        set_urls("https://download.libsodium.org/libsodium/releases/libsodium-$(version)-msvc.zip",
                 "https://github.com/jedisct1/libsodium/releases/download/$(version)-RELEASE/libsodium-$(version)-msvc.zip")
        add_versions("1.0.18", "c1d48d85c9361e350931ffe5067559cd7405a697c655d26955fb568d1084a5f4")
        add_versions("1.0.19", "3a137c98f96e809cb8927ed7a658fd0173d842c2b36c2a1e1954495571517b22")
    elseif is_plat("linux", "macosx") then
        add_deps("autoconf", "automake", "libtool", "pkg-config")
        set_urls("https://download.libsodium.org/libsodium/releases/libsodium-$(version).tar.gz",
                 "https://github.com/jedisct1/libsodium/releases/download/$(version)-RELEASE/libsodium-$(version).tar.gz")
        add_versions("1.0.18", "6f504490b342a4f8a4c4a02fc9b866cbef8622d5df4e5452b46be121e46636c1")
        add_versions("1.0.19", "018d79fe0a045cca07331d37bd0cb57b2e838c51bc48fd837a1472e50068bbea")
    elseif is_plat("mingw") then
        set_urls("https://download.libsodium.org/libsodium/releases/libsodium-$(version)-mingw.tar.gz",
                 "https://github.com/jedisct1/libsodium/releases/download/$(version)-RELEASE/libsodium-$(version)-mingw.tar.gz")
        add_versions("1.0.18", "e499c65b1c511cbc6700e436deb3771c3baa737981114c9e9f85f2ec90176861")
        add_versions("1.0.19", "fdd43a21a5ffd2933e6dd5563ecade2788ae94a054fde4188ce70755a68f43dd")
    end

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "SODIUM_STATIC")
        end
    end)

    on_install("windows", function (package)
        os.cp("include", package:installdir())
        os.cp(path.join((package:is_arch("x64") and "x64" or "Win32"), (package:debug() and "Debug" or "Release"), "v142", (package:config("shared") and "dynamic" or "static"), "*"), package:installdir("lib"))
    end)

    on_install("mingw", function (package)

        local root_dir = (package:is_arch("x86_64") and "libsodium-win64" or "libsodium-win32")

        os.cp(path.join(root_dir, "include"), package:installdir())
        if package:config("shared") then
            os.cp(path.join(root_dir, "lib", "libsodium.dll.a"), package:installdir("lib"))
            os.cp(path.join(root_dir, "bin", "*"), package:installdir("lib"))
        else
            os.cp(path.join(root_dir, "lib", "libsodium.a"), package:installdir("lib"))
        end
    end)

    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            int test(int args, char** argv) {
                if (sodium_init() < 0) {
                    return -1;
                }
                return 0;
            }
        ]]}, {includes = "sodium.h"}))
    end)
