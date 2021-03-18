package("ndk")

    set_kind("toolchain")
    set_homepage("https://developer.android.com/ndk")
    set_description("Android NDK toolchain.")

    local versions = {["21"] = "r21e", ["22"] = "r22"}
    if is_host("windows") then
        set_urls("https://dl.google.com/android/repository/android-ndk-$(version)-windows-x86_64.zip", {version = function (version)
            return versions[tostring(version:major())]
        end})
        add_versions("21.0", "f71307c5c572e2c163d602b3704b8bc024bec0c43ba2800de36bd10f3a21492b")
        add_versions("22.0", "5a0eafa83c8bba3c76e8427aa3d83d169215f62963a277b1914a3651aa47f751")
    elseif is_host("linux") then
        set_urls("https://dl.google.com/android/repository/android-ndk-$(version)-linux-x86_64.zip", {version = function (version)
            return versions[tostring(version:major())]
        end})
        add_versions("21.0", "ad7ce5467e18d40050dc51b8e7affc3e635c85bd8c59be62de32352328ed467e")
        add_versions("22.0", "d37fc69cd81e5660234a686e20adef39bc0244086e4d66525a40af771c020718")
    elseif is_host("macosx") then
        set_urls("https://dl.google.com/android/repository/android-ndk-$(version)-darwin-x86_64.zip", {version = function (version)
            return versions[tostring(version:major())]
        end})
        add_versions("21.0", "437278103a3db12632c05b1be5c41bbb8522791a67e415cc54411a65366f499d")
        add_versions("22.0", "14fce4dea7fb3facbc0e3d20270007bffec3ba383aec02e8b0e0dad8d8782892")
    end

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
