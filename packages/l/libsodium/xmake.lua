package("libsodium")

    set_homepage("https://libsodium.org")
    set_description("Sodium is a new, easy-to-use software library for encryption, decryption, signatures, password hashing and more.")

    if is_plat("windows") then
        set_urls("https://download.libsodium.org/libsodium/releases/libsodium-$(version)-msvc.zip",
                 "https://github.com/jedisct1/libsodium/releases/download/$(version)-RELEASE/libsodium-$(version)-msvc.zip")
        add_versions("1.0.18", "c1d48d85c9361e350931ffe5067559cd7405a697c655d26955fb568d1084a5f4")
    elseif is_plat("linux", "macosx") then
        add_deps("autoconf", "automake", "libtool", "pkg-config")
        set_urls("https://download.libsodium.org/libsodium/releases/libsodium-$(version).tar.gz",
                 "https://github.com/jedisct1/libsodium/releases/download/$(version)-RELEASE/libsodium-$(version).tar.gz")
        add_versions("1.0.18", "6f504490b342a4f8a4c4a02fc9b866cbef8622d5df4e5452b46be121e46636c1")
    elseif is_plat("mingw") then
        set_urls("https://download.libsodium.org/libsodium/releases/libsodium-$(version)-mingw.tar.gz",
                 "https://github.com/jedisct1/libsodium/releases/download/$(version)-RELEASE/libsodium-$(version)-mingw.tar.gz")
        add_versions("1.0.18", "e499c65b1c511cbc6700e436deb3771c3baa737981114c9e9f85f2ec90176861")
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
