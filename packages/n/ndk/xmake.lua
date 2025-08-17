package("ndk")
    set_kind("toolchain")
    set_homepage("https://developer.android.com/ndk")
    set_description("Android NDK toolchain.")

    if is_host("windows", "linux", "macosx") then
        set_urls("https://dl.google.com/android/repository/android-ndk-$(version).zip", {version = function(version)
            -- 27.3 -> r27d-linux
            local minor = ''
            local suffix = ''
            local host = os.host()
            if version:minor() > 0 then
                minor = string.char(97 + version:minor())
            end
            if version:major() < 23 then
                suffix = '-x86_64'
            end
            if host == "macosx" then
                host = "darwin"
            end
            return ("r%s%s-%s%s"):format(version:major(), minor, host, suffix)
        end})
    end

    if is_host("windows") then
        add_versionfiles("versions/windows.txt")
    elseif is_host("linux") then
        add_versionfiles("versions/linux.txt")
    elseif is_host("macosx") then
        add_versionfiles("versions/macosx.txt")
    end

    on_load(function (package)
        package:mark_as_pathenv("ANDROID_NDK_ROOT")
        package:mark_as_pathenv("ANDROID_NDK_HOME")
        package:setenv("ANDROID_NDK_ROOT", ".")
        package:setenv("ANDROID_NDK_HOME", ".")
    end)

    on_check("@macosx|arm64", function(package)
        assert(package:version():gt("23.0"), "package(ndk <=23.0): unsupported architecture, please increase the NDK version.")
    end)

    on_install("@windows|x64", "@msys|x86_64", "@linux|x86_64", "@macosx", function (package)
        os.vcp("*", package:installdir())
    end)

    on_test(function (package)
        local host = os.host()
        if host == "macosx" then
            host = "darwin"
        end
        os.vrunv(path.join(package:installdir(), "toolchains/llvm/prebuilt", host .. "-x86_64", "bin/clang"), {"--version"})
    end)
