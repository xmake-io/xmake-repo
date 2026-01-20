package("aqt")
    set_kind("binary")
    set_homepage("https://github.com/miurahr/aqtinstall")
    set_description("aqt: Another (unofficial) Qt CLI Installer on multi-platforms")
    set_license("MIT")

    add_configs("shared", {description = "Download shared binaries.", default = true, type = "boolean", readonly = true})

    if is_host("windows") and (os.arch() == "x64" or os.arch() == "x86") then
        add_configs("runtimes", {description = "Set compiler runtimes.", default = "MD", readonly = true})

        if os.arch() == "x86" then
            add_urls("https://github.com/miurahr/aqtinstall/releases/download/v$(version)/aqt_x86.exe")
            add_versions("3.3.0", "372ed5c099f2e010284e9a69cca0731b7dbf29be41100588685c2cd1f917bc40")
            add_versions("3.1.21", "b79465e771a78a76a8967c4bc49ac93210e25d6ead58b929a57100b3c6da71df")
            add_versions("3.1.17", "d3abbd3378907f2e3ebf3af3387590245bb04175e1a720d04463b047732e1cd2")
            add_versions("3.1.6", "093b536fab2e3726a792cdb60292313c0c8950b8aa9b56ccdeff7adb1146f964")
            add_versions("3.0.2", "aac5d8949eed3f231bfc589736afe0f88372dc590182c8b3a2bed7c78952b944")
            add_versions("2.0.6", "b980985cfeb1cefef1d2ebab91ae4e648873a27fae8831deff8144661480c56a")
        else
            add_urls("https://github.com/miurahr/aqtinstall/releases/download/v$(version)/aqt_x64.exe")
            add_versions("3.3.0", "4f74d4c95c464d238d7e17ec2d9b7f22a7c333f0f5270a62584e2b47fc765150")
            add_versions("3.1.21", "da834e08268f3ffbb4c3e1c3e8a3ef8885d446e96e48dd35780a8d73e4a9e4ed")
            add_versions("3.1.17", "02acc10c6317a2a9f76464d5c26b129b836531f81938b2b222498c495d69fcdb")
            add_versions("3.1.6", "4f7e3fbc2d155f903ed9597b7929201681ffb7628e97765511cc7efa8a60f3e6")
            add_versions("3.0.2", "96e46eca0d18a899db00a26facd20c799f2400645aef6445d49f4bd0aeab0a3f")
            add_versions("2.0.6", "b0ad07fe8fd2c094425449f3053598959e467833dadf509da948571259510078")
        end
    elseif is_host("macosx") and (os.arch() == "arm64" or os.arch() == "x86_64") then
        add_urls("https://github.com/miurahr/aqtinstall/releases/download/v$(version)/aqt-macos")
        add_versions("3.3.0", "fcc241c15ef6b9880b1ecb1f162fc9eca439f0628ae962eb20ba45dc279abe1a")
        add_versions("3.1.21", "aa720dbf0928b0843d02b06273086d0e4974b742461783c343b6ddde5ec7e0be")
        add_versions("3.1.17", "cb51decbc12500d2e3e4b743dd4abb86a91fd9f25a916cafe54572963acf0690")
    else
        add_deps("7z")
        add_deps("python >=3.6", {kind="binary"})
    end

    on_install("@macosx", "@linux", "@windows", "@msys", function (package)
        if is_host("windows") and (os.arch() == "x64" or os.arch() == "x86") then
            os.cp(package:originfile(), path.join(package:installdir("bin"), "aqt.exe"))
        elseif is_host("macosx") and (os.arch() == "arm64" or os.arch() == "x86_64") then
            os.cp(package:originfile(), path.join(package:installdir("bin"), "aqt"))
            os.vrunv("chmod", {"+x", path.join(package:installdir("bin"), "aqt")})
        else
            -- ensurepip has been dropped in recent releases
            try {function () os.vrunv("python3", {"-m", "ensurepip"}) end}

            os.vrunv("python3", {"-m", "pip", "install", "-U", "pip"})
            os.vrunv("python3", {"-m", "pip", "install", "aqtinstall"})
        end
    end)

    on_test(function (package)
        os.vrun("aqt -h")
    end)
    
