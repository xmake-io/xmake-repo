package("msvc")
    set_kind("toolchain")
    set_homepage("https://visualstudio.microsoft.com/zh-hans/visual-cpp-build-tools/")
    set_description("Microsoft Visual C/C++ Compiler")

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
            elseif is_host("linux") then
                -- TODO use msvc-wine
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

        -- get confirm result
        local result = utils.confirm({description = function ()
            cprint("${bright color.warning}note: ${clear}Do you accept the license agreement for installing msvc build toolchain?")
            cprint("  https://go.microsoft.com/fwlink/?LinkId=2179911")
        end, answer = function ()
            cprint("please input: ${bright}y/n${clear}")
            io.flush()
            return (io.read() or "n"):trim()
        end})

        if result and result ~= "n" then
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
        end
    end)

    on_test(function (package)
        assert(os.isfile(path.join(package:installdir(), "devcmd.bat")))
    end)


