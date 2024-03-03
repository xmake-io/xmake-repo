package("libsodium")
    set_homepage("https://libsodium.org")
    set_description("Sodium is a new, easy-to-use software library for encryption, decryption, signatures, password hashing and more.")
    set_license("ISC")

    if not is_plat("mingw") then
        set_urls("https://download.libsodium.org/libsodium/releases/libsodium-$(version).tar.gz",
                 "https://github.com/jedisct1/libsodium/releases/download/$(version)-RELEASE/libsodium-$(version).tar.gz",
                 "https://github.com/jedisct1/libsodium.git")
        add_versions("1.0.19", "018d79fe0a045cca07331d37bd0cb57b2e838c51bc48fd837a1472e50068bbea")
        add_versions("1.0.18", "6f504490b342a4f8a4c4a02fc9b866cbef8622d5df4e5452b46be121e46636c1")
    else
        set_urls("https://download.libsodium.org/libsodium/releases/libsodium-$(version)-mingw.tar.gz",
                 "https://github.com/jedisct1/libsodium/releases/download/$(version)-RELEASE/libsodium-$(version)-mingw.tar.gz")
        add_versions("1.0.18", "e499c65b1c511cbc6700e436deb3771c3baa737981114c9e9f85f2ec90176861")
        add_versions("1.0.19", "fdd43a21a5ffd2933e6dd5563ecade2788ae94a054fde4188ce70755a68f43dd")
    end

    if not is_plat("windows") then
        add_deps("autoconf", "automake", "libtool", "pkg-config")
    end

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "SODIUM_STATIC")
        end
    end)

    on_install("windows", function (package)
        import("core.tool.toolchain")

        local msvc = toolchain.load("msvc")
        local vsversion = msvc:config("vs") or "2019"

        local previousdir = os.cd(path.join("builds", "msvc", "vs" .. vsversion))

        local mode = package:config("shared") and "Dyn" or "Static"
        mode = mode .. (package:debug() and "Debug" or "Release")

        local configs = {"libsodium.sln"}
        table.insert(configs, "/p:Configuration=" .. mode)
        import("package.tools.msbuild").build(package, configs)

        os.cd(previousdir)
        os.tryrm("src/libsodium/include/Makefile.*")
        os.vcp("src/libsodium/include", package:installdir())
        os.vcp("bin/**/libsodium.dll", package:installdir("bin"))
        os.vcp("bin/**/libsodium.lib", package:installdir("lib"))
        os.vcp("bin/**/libsodium.pdb", package:installdir(package:config("shared") and "bin" or "lib"))
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

    on_install("linux", "macosx", "android", "iphoneos", "bsd", "wasm", function (package)
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
