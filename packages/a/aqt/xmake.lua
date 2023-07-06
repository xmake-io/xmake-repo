package("aqt")
    set_kind("binary")
    set_homepage("https://github.com/miurahr/aqtinstall")
    set_description("aqt: Another (unofficial) Qt CLI Installer on multi-platforms")
    set_license("MIT")

    if is_host("windows") and (os.arch() == "x64" or os.arch() == "x86") then
        add_configs("shared", {description = "Download shared binaries.", default = true, type = "boolean", readonly = true})
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})

        if os.arch() == "x86" then
            add_urls("https://github.com/miurahr/aqtinstall/releases/download/v$(version)/aqt_x86_signed.exe", { alias = "signed" })
            add_urls("https://github.com/miurahr/aqtinstall/releases/download/v$(version)/aqt_x86.exe", { alias = "regular" })
            add_versions("signed:3.1.6", "dc675b64caceaacaf2d2bd711fb7a005ab2bcf7f6a28702e52408965f65718ec")
            add_versions("regular:3.1.6", "093b536fab2e3726a792cdb60292313c0c8950b8aa9b56ccdeff7adb1146f964")
            add_versions("regular:3.0.2", "aac5d8949eed3f231bfc589736afe0f88372dc590182c8b3a2bed7c78952b944")
            add_versions("regular:2.0.6", "b980985cfeb1cefef1d2ebab91ae4e648873a27fae8831deff8144661480c56a")
        else
            add_urls("https://github.com/miurahr/aqtinstall/releases/download/v$(version)/aqt_x64_signed.exe", { alias = "signed" })
            add_urls("https://github.com/miurahr/aqtinstall/releases/download/v$(version)/aqt_x64.exe", { alias = "regular" })
            add_versions("signed:3.1.6", "ca988c2aedaed379d1672e95ed38f91be5e803a5f2947b25c29e8b28fb2bd5c8")
            add_versions("regular:3.1.6", "4f7e3fbc2d155f903ed9597b7929201681ffb7628e97765511cc7efa8a60f3e6")
            add_versions("regular:3.0.2", "96e46eca0d18a899db00a26facd20c799f2400645aef6445d49f4bd0aeab0a3f")
            add_versions("regular:2.0.6", "b0ad07fe8fd2c094425449f3053598959e467833dadf509da948571259510078")
        end
    else
        add_deps("7z")
        add_deps("python >=3.6", {kind="binary"})
    end

    on_install("@macosx", "@linux", "@windows", "@msys", function (package)
        if is_host("windows") and (os.arch() == "x64" or os.arch() == "x86") then
            os.mv(package:originfile(), path.join(package:installdir("bin"), "aqt.exe"))
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
