package("ndk")

    set_kind("toolchain")
    set_homepage("https://developer.android.com/ndk")
    set_description("Android NDK toolchain.")

    local versions = {["21"] = "r21e"}
    if is_host("windows") then
        set_urls("https://dl.google.com/android/repository/android-ndk-$(version)-windows-x86_64.zip", {version = function (version)
            return versions[tostring(version)]
        end})
        add_versions("21", "f71307c5c572e2c163d602b3704b8bc024bec0c43ba2800de36bd10f3a21492b")
    elseif is_host("linux") then
        set_urls("https://dl.google.com/android/repository/android-ndk-$(version)-linux-x86_64.zip", {version = function (version)
            return versions[tostring(version)]
        end})
        add_versions("21", "ad7ce5467e18d40050dc51b8e7affc3e635c85bd8c59be62de32352328ed467e")
    elseif is_host("macosx") then
        set_urls("https://dl.google.com/android/repository/android-ndk-$(version)-darwin-x86_64.zip", {version = function (version)
            return versions[tostring(version)]
        end})
        add_versions("21", "437278103a3db12632c05b1be5c41bbb8522791a67e415cc54411a65366f499d")
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
