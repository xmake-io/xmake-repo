package("yy-thunks")

    set_homepage("https://github.com/Chuyu-Team/YY-Thunks")
    set_description("Fix DecodePointer, EncodePointer,RegDeleteKeyEx etc. APIs not found in Windows XP RTM.")
    set_license("MIT")

    add_urls("https://github.com/Chuyu-Team/YY-Thunks/releases/download/v$(version)/YY-Thunks-$(version)-Binary.zip")
    add_versions("1.0.7", "3607a79ac37f141cbcbf00aaea8d82a4c2628d81d8dad9e2a4dce4c8c17a025b")

    on_install("windows|x64", "windows|x86", function (package)
        import("core.tool.toolchain")

        -- check vs version
        local vs = toolchain.load("msvc"):config("vs")
        if tonumber(vs) < 2005 then
            raise("YY-Thunks only supports VS2008 or later versions")
        end

        if package:is_arch("x64") then
            os.cp("objs/x64/*.obj", package:installdir("lib"))
        elseif package:is_arch("x86") then
            os.cp("objs/x86/*.obj", package:installdir("lib"))
        else
            raise("Unsupported architecture!")
        end
    end)

    on_test(function (package)
        local obj = path.join(package:installdir("lib"), "YY_Thunks_for_WinXP.obj")
        assert(os.isfile(obj))
    end)
