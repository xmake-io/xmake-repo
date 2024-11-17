package("openjdk")
    set_kind("binary")
    set_homepage("https://jdk.java.net")
    set_description("Java Development Kit builds, from Oracle")
    set_license("GPL-2.0")

    -- https://learn.microsoft.com/en-us/java/openjdk/download
    if is_host("windows") then
        if os.arch() == "x64" then
            add_urls("https://aka.ms/download-jdk/microsoft-jdk-$(version)-windows-x64.zip")

            add_versions("21.0.5", "12e42c2c572a111f38e2a9e044afc50dbdac850349a4d4bb26808ed33119a9cd")
        elseif os.arch() == "arm64" then
            add_urls("https://aka.ms/download-jdk/microsoft-jdk-$(version)-windows-aarch64.zip")

            add_versions("21.0.5", "5eaa375659c543a5d3310d51004e3bdc290ff9e48e9bcd29187dfafeca97c2a4")
        end
    elseif is_host("linux") then
        if os.arch() == "x86_64" then
            add_urls("https://aka.ms/download-jdk/microsoft-jdk-$(version)-linux-x64.tar.gz")

            add_versions("21.0.5", "0d42a80dbc92f2f112e6db3b4b9bd278c0776a73b6050812e720230813487ebd")
        elseif os.arch() == "arm64-v8a" then
            add_urls("https://aka.ms/download-jdk/microsoft-jdk-$(version)-linux-aarch64.tar.gz")

            add_versions("21.0.5", "356844fe544085b00cd73935e0c7a4c534f286799728fa6d6e996d1cb8b1a682")
        end
    elseif is_host("macosx") then
        if os.arch() == "x86_64" then
            add_urls("https://aka.ms/download-jdk/microsoft-jdk-$(version)-macos-x64.tar.gz")

            add_versions("21.0.5", "3e2317348141b28203fac39eaa60c14a1b3f1fdb9cfdbcb793eaa4dd5828da6e")
        elseif os.arch() == "arm64" then
            add_urls("https://aka.ms/download-jdk/microsoft-jdk-$(version)-macos-aarch64.tar.gz")

            add_versions("21.0.5", "78aa915475b426c03059cc51e9c12596a5138457bd7ebb9b90daad119551662d")
        end
    end

    add_configs("shared", {description = "Download shared binaries.", default = true, type = "boolean", readonly = true})
    add_configs("runtimes", {description = "Set compiler runtimes.", default = "MD", readonly = true})
    add_configs("debug", {description = "Enable debug symbols.", default = false, type = "boolean", readonly = true})

    if is_plat("linux") then
        add_extsources("pacman::jdk-openjdk", "apt::default-jdk")
    elseif is_plat("macosx") then
        add_extsources("brew::openjdk")
    end

    if is_plat("linux") then
        add_deps("alsa-lib", {configs = {shared = true, versioned = false}})
        add_deps("freetype", "libxtst", "libxi", "libxrender")
    end

    set_policy("package.precompiled", false)

    on_fetch("fetch")

    if on_check then
        on_check(function (package)
            if not package:is_arch64() then
                raise("package(openjdk) unsupported 32-bit arch")
            end
        end)
    end

    on_install("windows|!x86", "linux", "macosx", function (package)
        local plat
        if package:is_plat("windows", "mingw") then
            plat = "win32"
            package:add("bindirs", "bin/server")
        else
            package:add("linkdirs", "lib", "lib/server")
            if package:is_plat("linux") then
                plat = "linux"
            elseif package:is_plat("macosx") then
                plat = "darwin"
                os.cd("Contents/Home")
            end
        end

        os.cp("bin", package:installdir())
        os.cp("include", package:installdir())
        os.cp("lib", package:installdir())
        os.cp("jmods", package:installdir("lib"))
        os.cp("conf", package:installdir())

        package:add("includedirs", "include", path.join("include", plat))
        package:add("bindirs", "bin")
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("java -version")
        end
        if package:is_library() then
            assert(package:has_cfuncs("JNI_CreateJavaVM", {includes = "jni.h"}))
        end
    end)
