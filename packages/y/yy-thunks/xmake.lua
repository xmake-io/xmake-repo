package("yy-thunks")
    set_homepage("https://github.com/Chuyu-Team/YY-Thunks")
    set_description("Fix DecodePointer, EncodePointer,RegDeleteKeyEx etc. APIs not found in Windows XP RTM.")
    set_license("MIT")

    add_urls("https://github.com/Chuyu-Team/YY-Thunks/releases/download/v$(version)-Objs.zip", {
        version = function (version)
            if version:ge("1.1.6") then
                return format("%s/YY-Thunks", version)
            else
                return format("%s/YY-Thunks-%s", version, version)
            end
        end
    })
    add_urls("https://github.com/Chuyu-Team/YY-Thunks/releases/download/v$(version)/YY-Thunks-$(version)-Binary.zip")

    add_versions("1.1.9", "c53b87f83a3a1322de22195ee43fca590e757369b713304a4ce4fcaad532f8b7")
    add_versions("1.1.8", "2c5ef3c2e8a3abc366ed1ab233f46e60951eb1250a5f1a5b1527ed6983bf4e74")
    add_versions("1.1.7", "c3066f3f074ebc2a89b2def5f427bdea238dee17349d2bab579af519781691ab")
    add_versions("1.1.6", "fa4de6bda69f476907f780f63f3dda792537a2e3236cd23043a490c6b91cb0b5")
    add_versions("1.1.5", "e6e2bb6e6b46f8b2b4af4cff2b2b754b123837a3c72f1cd5d7a5bfdf3c0df82a")
    add_versions("1.1.4", "f9850a35d1f2b0cae15e64da516de0ec5e798c060b320e91788aa33b853e85ba")
    add_versions("1.1.1", "fe79e309aa42a58794609e06382632a0b768a1193a6bb5aad0bddd4264712aba")
    add_versions("1.0.9", "216b88757f28075d3d8c0363139e870d49ba84458fc10a0f094f264ebf0a302c")
    add_versions("1.0.7", "3607a79ac37f141cbcbf00aaea8d82a4c2628d81d8dad9e2a4dce4c8c17a025b")

    add_configs("debug", {description = "Enable debug symbols.", default = false, readonly = true})
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    set_policy("package.precompiled", false)

    on_install("windows|x64", "windows|x86", function (package)
        -- check vs version
        local vs = package:toolchain("msvc"):config("vs")
        if vs and tonumber(vs) < 2005 then
            raise("YY-Thunks only supports VS2008 or later versions")
        end

        if package:is_arch("x64") then
            os.mv("objs/x64/*.obj", package:installdir("lib"))
        elseif package:is_arch("x86") then
            os.mv("objs/x86/*.obj", package:installdir("lib"))
        else
            raise("Unsupported architecture!")
        end
        os.trymv("YY.Depends.Analyzer.exe", package:installdir("bin"))
    end)

    on_test(function (package)
        local obj = path.join(package:installdir("lib"), "YY_Thunks_for_WinXP.obj")
        assert(os.isfile(obj))
    end)
