package("yy-thunks")
    set_homepage("https://github.com/Chuyu-Team/YY-Thunks")
    set_description("Fix DecodePointer, EncodePointer,RegDeleteKeyEx etc. APIs not found in Windows XP RTM.")
    set_license("MIT")

    add_urls("https://github.com/Chuyu-Team/YY-Thunks/releases/download/v$(version)/YY-Thunks-$(version)-Objs.zip")
    add_urls("https://github.com/Chuyu-Team/YY-Thunks/releases/download/v$(version)/YY-Thunks-$(version)-Binary.zip")

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
