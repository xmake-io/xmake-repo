package("libsodium")

    set_homepage("https://libsodium.org")
    set_description("Sodium is a new, easy-to-use software library for encryption, decryption, signatures, password hashing and more.")

    if is_plat("windows") then
        set_urls("https://download.libsodium.org/libsodium/releases/libsodium-$(version)-stable-msvc.zip")
        add_versions("1.0.18", "5d313795d13fc99fb925c4d49c16f1a80779f69e49b58a9a4260bd3b150d45b7")
    elseif is_plat("linux", "macosx") then
        add_deps("autoconf", "automake", "libtool", "pkg-config")
        set_urls("https://download.libsodium.org/libsodium/releases/libsodium-$(version)-stable.tar.gz")
        add_versions("1.0.18", "91441b13c965e241cd64bb42823f1f2d882f08f8f40f1716cda17df2b3450af2")
    elseif is_plat("mingw") then
        set_urls("https://download.libsodium.org/libsodium/releases/libsodium-$(version)-stable-mingw.tar.gz")
        add_versions("1.0.18", "d2f1918e198cd86b9e6ba05b2f5c2dc86753875ea3ee887892767231c6b7e121")
    end

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "SODIUM_STATIC")
        end
    end)
    
    on_install("windows", function (package)
        os.cp("include", package:installdir())
        os.cp(path.join((package:is_plat("x86") and "Win32" or "x64"), (package:debug() and "Debug" or "Release"), "v142", (package:config("shared") and "dynamic" or "static"), "*"), package:installdir("lib"))
    end)

    on_install("mingw", function (package)

        local root_dir = (package:is_plat("x86") and "libsodium-win32" or "libsodium-win64")

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
