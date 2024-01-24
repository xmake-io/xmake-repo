package("ndk")
    set_kind("toolchain")
    set_homepage("https://developer.android.com/ndk")
    set_description("Android NDK toolchain.")

    if is_host("windows") then
        local versions = {["21"] = "r21e-windows-x86_64", ["22"] = "r22-windows-x86_64", ["26"] = "r26b-windows"}
        set_urls("https://dl.google.com/android/repository/android-ndk-$(version).zip", {version = function (version)
            return versions[tostring(version:major())]
        end})
        add_versions("21.0", "f71307c5c572e2c163d602b3704b8bc024bec0c43ba2800de36bd10f3a21492b")
        add_versions("22.0", "5a0eafa83c8bba3c76e8427aa3d83d169215f62963a277b1914a3651aa47f751")
        add_versions("26.0", "a478d43d4a45d0d345cda6be50d79642b92fb175868d9dc0dfc86181d80f691e")
    elseif is_host("linux") then
        local versions = {["21"] = "r21e-linux-x86_64", ["22"] = "r22-linux-x86_64", ["26"] = "r26b-linux"}
        set_urls("https://dl.google.com/android/repository/android-ndk-$(version).zip", {version = function (version)
            return versions[tostring(version:major())]
        end})
        add_versions("21.0", "ad7ce5467e18d40050dc51b8e7affc3e635c85bd8c59be62de32352328ed467e")
        add_versions("22.0", "d37fc69cd81e5660234a686e20adef39bc0244086e4d66525a40af771c020718")
        add_versions("26.0", "ad73c0370f0b0a87d1671ed2fd5a9ac9acfd1eb5c43a7fbfbd330f85d19dd632")
    elseif is_host("macosx") then
        local versions = {["21"] = "r21e-darwin-x86_64", ["22"] = "r22-darwin-x86_64", ["26"] = "r26b-darwin"}
        set_urls("https://dl.google.com/android/repository/android-ndk-$(version)-darwin.zip", {version = function (version)
            return versions[tostring(version:major())]
        end})
        add_versions("21.0", "437278103a3db12632c05b1be5c41bbb8522791a67e415cc54411a65366f499d")
        add_versions("22.0", "14fce4dea7fb3facbc0e3d20270007bffec3ba383aec02e8b0e0dad8d8782892")
        add_versions("26.0", "4b0ea6148a9a2337e62a0c0c7ac59ff1edc38d69b81d9c58251897d23f7fa321")
    end

    on_fetch(function (package, opt)
        if opt.system then
            import("core.base.semver")
            import("detect.sdks.find_ndk")
            local ndk = find_ndk()
            if ndk and ndk.ndkver and semver.satisfies(ndk.ndkver .. ".0", opt.require_version) then
                return true
            end
        end
    end)

    on_install("@windows", "@msys", "@linux", "@macosx", function (package)
        os.vcp("*", package:installdir())
    end)

    on_test(function (package)
        local host = os.host()
        if host == "macosx" then
            host = "darwin"
        end
        os.vrunv(path.join(package:installdir(), "toolchains/llvm/prebuilt", host .. "-x86_64", "bin/clang"), {"--version"})
    end)
