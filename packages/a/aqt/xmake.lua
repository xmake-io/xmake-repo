package("aqt")

    set_kind("binary")
    set_homepage("https://github.com/miurahr/aqtinstall")
    set_description("aqt: Another (unofficial) Qt CLI Installer on multi-platforms")
    set_license("MIT")

    if is_host("windows") then
        add_configs("shared", {description = "Download shared binaries.", default = true, type = "boolean", readonly = true})
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})

        if os.arch() == "x86" then
            add_urls("https://github.com/miurahr/aqtinstall/releases/download/v$(version)/aqt_x86.exe")
            add_versions("2.0.6", "b980985cfeb1cefef1d2ebab91ae4e648873a27fae8831deff8144661480c56a")
        else
            add_urls("https://github.com/miurahr/aqtinstall/releases/download/v$(version)/aqt_x64.exe")
            add_versions("2.0.6", "b0ad07fe8fd2c094425449f3053598959e467833dadf509da948571259510078")
        end
    else
        add_deps("python >=3.6", "7z")
    end

    on_install(function (package)
        if is_host("windows") then
            os.mv(package:originfile(), path.join(package:installdir("bin"), "aqt.exe"))
        else
            -- ensurepip has been dropped in recent releases
            try
            {
                function () os.vrunv("python3", {"-m", "ensurepip"}) end
            }

            os.vrunv("python3", {"-m", "pip", "install", "-U", "pip"})
            os.vrunv("python3", {"-m", "pip", "install", "aqtinstall"})
        end
    end)

    on_test(function (package)
        os.vrun("aqt -h")
    end)
