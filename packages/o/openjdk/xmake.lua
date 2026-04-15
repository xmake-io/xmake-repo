package("openjdk")
    set_kind("binary")
    set_homepage("https://jdk.java.net")
    set_description("Java Development Kit builds, from Oracle")
    set_license("GPL-2.0")

    -- https://learn.microsoft.com/en-us/java/openjdk/download
    if is_host("windows") then
        if is_arch("x64", "x86_64") or os.arch() == "x64" then
            add_urls("https://aka.ms/download-jdk/microsoft-jdk-$(version)-windows-x64.zip")

            add_versions("21.0.5", "12e42c2c572a111f38e2a9e044afc50dbdac850349a4d4bb26808ed33119a9cd")
            add_versions("21.0.10", "45a44af1f832e720ea6ad90dd7b2c94a48b2e5bf2fab92b2403e975f78d7d5e1")
            add_versions("25.0.2", "38d1a42d189c50b24152014ef131931f25f4cc80400ce618f0477f5e4e5aa252")
        elseif os.arch() == "arm64" then
            add_urls("https://aka.ms/download-jdk/microsoft-jdk-$(version)-windows-aarch64.zip")

            add_versions("21.0.5", "5eaa375659c543a5d3310d51004e3bdc290ff9e48e9bcd29187dfafeca97c2a4")
            add_versions("21.0.10", "924c7127929aeb90019c1982a26b0a88337aed00ef333afb0bec28c06a6b5767")
            add_versions("25.0.2", "e0d9380cf3d0b5efc675664fa0db22cc9eb5d77c4fd2a132f4b58df0608593cf")
        end
    elseif is_host("linux") then
        if os.arch() == "x86_64" then
            add_urls("https://aka.ms/download-jdk/microsoft-jdk-$(version)-linux-x64.tar.gz")

            add_versions("21.0.5", "0d42a80dbc92f2f112e6db3b4b9bd278c0776a73b6050812e720230813487ebd")
            add_versions("21.0.10", "18ca81d9cbca9b34eb3976c515310dc025efeb23c90616e3faa61c275acf60fd")
            add_versions("25.0.2", "3ed688a48c9b9295e67f074a5d201f761af15f83a2e003e5d8fd6dd93c18a10a")
        elseif os.arch() == "arm64" then
            add_urls("https://aka.ms/download-jdk/microsoft-jdk-$(version)-linux-aarch64.tar.gz")

            add_versions("21.0.5", "356844fe544085b00cd73935e0c7a4c534f286799728fa6d6e996d1cb8b1a682")
            add_versions("21.0.10", "5d80661f5a55c6d0f3abba2b8196b269fa6a490142f4c751c8373058c00ba233")
            add_versions("25.0.2", "bdc5fffc0d1e741ab7840b8e733fca48b70d1b6838db4d90b94a78b90e6ea8cb")
        end
    elseif is_host("macosx") then
        if os.arch() == "x86_64" then
            add_urls("https://aka.ms/download-jdk/microsoft-jdk-$(version)-macos-x64.tar.gz")

            add_versions("21.0.5", "3e2317348141b28203fac39eaa60c14a1b3f1fdb9cfdbcb793eaa4dd5828da6e")
            add_versions("21.0.10", "b4c94a74d06e1046480ebe35e01e038b532e966b10ff797dc8d530ee75fa560e")
            add_versions("25.0.2", "6bc02fd3182dee12510f253d08eeac342a1f0e03d7f4114763f83d8722e2915e")
        elseif os.arch() == "arm64" then
            add_urls("https://aka.ms/download-jdk/microsoft-jdk-$(version)-macos-aarch64.tar.gz")

            add_versions("21.0.5", "78aa915475b426c03059cc51e9c12596a5138457bd7ebb9b90daad119551662d")
            add_versions("21.0.10", "f480c5533d37564640fb831c6c1f3c674889bc5ffd363bb7019c69ea9335cf23")
            add_versions("25.0.2", "0bface8af5ceea3bf8b7eec6d38f1a68b68b60db5ea14eb2a1bd9767cf971fed")
        end
    end

    add_configs("shared", {description = "Download shared binaries.", default = true, type = "boolean", readonly = true})
    add_configs("debug", {description = "Enable debug symbols.", default = false, type = "boolean", readonly = true})
    if is_plat("windows") then
        add_configs("runtimes", {description = "Set compiler runtimes.", default = "MD", readonly = true})
    end

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

    on_install("windows|!x86", "msys|x86_64", "linux", "macosx", function (package)
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
