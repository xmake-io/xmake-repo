package("libsodium")

    set_homepage("https://libsodium.org")
    set_description("Sodium is a new, easy-to-use software library for encryption, decryption, signatures, password hashing and more.")
    
    if is_plat("windows") then
        add_urls("https://download.libsodium.org/libsodium/releases/libsodium-$(version)-stable-msvc.zip")
        add_versions("1.0.18", "5c9d3d4180068ae35263ed06e20abc6c29a1787e6b71a6fccf9690219b3d1e84")
    elseif is_plat("linux", "macosx") then
        add_deps("autoconf", "automake", "libtool", "pkg-config")
        add_urls("https://download.libsodium.org/libsodium/releases/libsodium-$(version)-stable.tar.gz")
        add_versions("1.0.18", "4ece375801c355dd9ad5aa48c85bfb40377f72507557499b6bfdddbcfdb15c74")
    elseif is_plat("mingw") then
        add_urls("https://download.libsodium.org/libsodium/releases/libsodium-$(version)-stable-mingw.tar.gz")
        add_versions("1.0.18", "1ad939e3098afd7d3e00ec4e0d84155a32988f14dede61dd39ddf1f95d6e14ad")
    end

    add_urls("https://github.com/jedisct1/libsodium.git")

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
