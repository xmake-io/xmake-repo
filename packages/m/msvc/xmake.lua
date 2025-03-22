package("msvc")
    set_kind("toolchain")
    set_homepage("https://visualstudio.microsoft.com/zh-hans/visual-cpp-build-tools/")
    set_description("Microsoft Visual C/C++ Compiler")
    if set_installtips then
        set_installtips("Do you accept the license agreement? https://go.microsoft.com/fwlink/?LinkId=2179911")
    end

    add_versions("14.43.17+13", "dummy")
    add_versions("14.42.17+12", "dummy")
    add_versions("14.41.17+11", "dummy")
    add_versions("14.40.17+10", "dummy")
    add_versions("14.39.17+9", "dummy")
    add_versions("14.38.17+8", "dummy")
    add_versions("14.37.17+7", "dummy")
    add_versions("14.36.17+6", "dummy")
    add_versions("14.35.17+5", "dummy")
    add_versions("14.34.17+4", "dummy")
    add_versions("14.33.17+3", "dummy")
    add_versions("14.32.17+2", "dummy")
    add_versions("14.31.17+1", "dummy")
    add_versions("14.30.17+0", "dummy")
    add_versions("14.29.16+11", "dummy")

    add_configs("preview", {description = "The Preview Version", type = "boolean"})
    add_configs("target", {description = "The Target architecture", type = "string", values = {"x64", "x86", "arm", "arm64"}})
    add_configs("sdkver", {description = "The Windows SDK Version", type = "string", values = {
        "10.0.26100",
        "10.0.22621",
        "10.0.22000",
        "10.0.20348",
        "10.0.19041",
        "10.0.18362"}})

    on_load(function (package)
        if not package:is_precompiled() then
            if is_host("windows") then
                package:add("deps", "portable_build_tools")
            elseif is_host("linux", "macosx") then
                package:add("deps", "msvc-wine")
                if is_host("macosx") then
                    package:add("deps", "brew::msitools", {private = true})
                else
                    if linuxos.name() == "archlinux" then
                        package:add("deps", "pacman::msitools", {private = true})
                    elseif linuxos.name() == "ubuntu" then
                        package:add("deps", "apt::msitools", {private = true})
                    end
                end
            end
        end
    end)

    on_fetch("@windows", "@msys", function (package, opt)
        if opt.system then
            -- TODO maybe we need to improve it
            if not package:config("sdkver") and not package:config("target") and not package:config("preview") then
                local msvc = package:toolchain("msvc")
                if msvc and msvc:check() then
                    return {}
                end
            end
        end
    end)

    on_install("@windows", "@msys", function (package)
        import("core.base.semver")

        local argv = {"accept_license"}
        local sdkver = semver.new(package:config("sdkver") or "10.0.26100")
        if package:config("preview") then
            table.insert(argv, "preview")
        end
        table.insert(argv, "msvc=" .. package:version_str():replace("+", ".", {plain = true}))
        table.insert(argv, "sdk=" .. sdkver:patch())
        table.insert(argv, "host=" .. os.arch())
        table.insert(argv, "env=none")
        table.insert(argv, "path=" .. package:installdir())
        table.insert(argv, "target=" .. (package:config("target") or os.arch()))

        -- @note It downloads the official binary source
        -- https://visualstudio.microsoft.com/zh-hans/visual-cpp-build-tools/
        -- https://github.com/Data-Oriented-House/PortableBuildTools/blob/3a2cd42b1de75da63ad30a55982d8dff3c36aa45/source.c#L724
        os.vrunv("PortableBuildTools.exe", argv)
    end)

    on_install("@linux", "@macosx", function (package)
        local argv = {"--accept-license"}
        if package:config("preview") then
            table.insert(argv, "--preview")
        end
        local msvc_version = package:version()
        table.insert(argv, "--major")
        table.insert(argv, msvc_version:patch())
        table.insert(argv, "--msvc-version")
        if msvc_version:patch() == 17 then
            table.insert(argv, "17.0")
        else
            table.insert(argv, format("%s.%s", msvc_version:patch(), msvc_version:build()[1]))
        end
        if package:config("sdkver") then
            table.insert(argv, "--sdk-version")
            table.insert(argv, package:config("sdkver"))
        end
        if package:config("target") then
            table.insert(argv, "--architecture")
            table.insert(argv, package:config("target"))
        end
        table.insert(argv, "--dest")
        table.insert(argv, package:installdir())

        local msvc_wine = package:dep("msvc-wine"):installdir()
        os.vrunv("python3", table.join(path.join(msvc_wine, "bin/vsdownload.py"), argv))
        os.vrunv(path.join("./", msvc_wine, "bin/install.sh"), {package:installdir()}, {shell = true})
    end)

    on_test(function (package)
        if is_host("windows") then
            assert(os.isfile(path.join(package:installdir(), "devcmd.bat")))
        elseif is_host("linux", "macosx") then
            local target = package:config("target") or "x64"
            assert(os.isfile(path.join(package:installdir(), format("bin/%s/cl.exe", target))))
        end
    end)
