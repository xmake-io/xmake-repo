package("qt5base")
    set_kind("phony")
    set_homepage("https://www.qt.io")
    set_description("Qt is the faster, smarter way to create innovative devices, modern UIs & applications for multiple screens. Cross-platform software development at its best.")
    set_license("LGPL-3")

    add_versions("5.15.2", "dummy")
    add_versions("5.12.5", "dummy")

    add_configs("shared", {description = "Download shared binaries.", default = true, type = "boolean", readonly = true})
    add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})

    add_deps("aqt")

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_fetch(function (package, opt)
        import("core.base.semver")
        import("detect.sdks.find_qt")

        local qt = package:data("qt")
        if qt then
            return qt
        end

        local sdkdir
        if not opt.system then
            sdkdir = package:installdir()
        end
        local qt = find_qt(sdkdir, {force = opt.force})
        if not qt then
            return
        end

        local qtversion = semver.new(qt.sdkver)
        if not qtversion:satisfies("5.x") then
            return
        end
        qt.version = qt.sdkver
        package:data_set("qt", qt)
        return qt
    end)

    on_install("windows|x86", "windows|x64", "linux", "macosx", "mingw", "android", "iphoneos", function (package)
        import("core.base.semver")
        import("core.project.config")
        import("core.tool.toolchain")

        local version = package:version()
        local versionstr = version:shortstr()

        local host
        if is_host("windows") or package:is_plat("mingw") then
            host = "windows"
        elseif is_host("linux") then
            host = "linux"
        elseif is_host("macosx") then
            host = "mac"
        else
            raise("unhandled host " .. os.host())
        end

        local target
        if package:is_plat("windows", "mingw", "linux", "macosx") then
            target = "desktop"
        elseif package:is_plat("android") then
            target = "android"
        elseif package:is_plat("iphoneos") then
            target = "ios"
        else
            raise("unhandled plat " .. package:plat())
        end

        local arch
        if package:is_plat("windows", "mingw") then
            local winarch
            if package:is_arch("x64", "x86_64") then
                winarch = "64"
            elseif package:is_arch("x86", "i386") then
                winarch = "32"
            else
                raise("unhandled arch " .. package:targetarch())
            end

            local compiler_version
            if package:is_plat("windows") then
                local vs = toolchain.load("msvc"):config("vs")
                if tonumber(vs) >= 2019 then
                    compiler_version = "msvc2019"
                elseif vs == "2017" or vs == "2015" then
                    compiler_version = "msvc" .. vs
                else
                    raise("unhandled msvc version " .. vs)
                end

                if package:is_arch("x64", "x86_64") then
                    compiler_version = compiler_version .. "_64"
                end
            else
                local cc = package:tool("cc")
                local version = os.iorunv(cc, {"-dumpversion"}):trim()
                local mingw_version = semver.new(version)
                if mingw_version:ge("8.1") then
                    compiler_version = "mingw81"
                elseif mingw_version:ge("7.3") then
                    compiler_version = "mingw73"
                elseif mingw_version:ge("5.3") then
                    compiler_version = "mingw53"
                else
                    raise("unhandled mingw version " .. version)
                end
            end
            arch = "win" .. winarch .. "_" .. compiler_version
        elseif package:is_plat("linux") then
            arch = "gcc_64"
        elseif package:is_plat("macosx") then
            arch = "clang_64"
        elseif package:is_plat("android") then
            if version:le("5.13") then
                if package:is_arch("x86_64", "x64") then
                    arch = "android_x86_64"
                elseif package:is_arch("arm64", "arm64-v8a") then
                    arch = "android_arm64_v8a"
                elseif package:is_arch("armv7", "armv7-a") then
                    arch = "android_armv7"
                elseif package:is_arch("x86") then
                    arch = "android_x86"
                end
            else
                arch = "android"
            end
        end

        local installdir = package:installdir()
        os.vrunv("aqt", {"install-qt", "-O", installdir, host, target, versionstr, arch})

        -- move files to root
        os.mv(path.join(installdir, versionstr, "*", "*"), installdir)
        os.rmdir(path.join(installdir, versionstr))

        -- special case for cross-compilation using MinGW since we need binaries we can run on the host
        if package:is_plat("mingw") and not is_host("windows") then
            local runhost
            if is_host("linux") then
                runhost = "linux"
            elseif is_host("macosx") then
                runhost = "mac"
            else
                raise("unhandled host " .. os.host())
            end

            -- download qtbase to bin_host folder
            os.vrunv("aqt", {"install-qt", "-O", path.join(installdir, "bin_host"), runhost, "desktop", versionstr, "--archives", "qtbase"})

            -- add symbolic links for useful tools
            local tools = {
                moc = true,
                qmake = true,
                rcc = true,
                uic = true
            }

            for _, file in pairs(os.files(path.join(installdir, "bin_host", versionstr, "*", "bin", "*"))) do
                local filename = path.filename(file)
                if (tools[filename]) then
                    local targetpath = path.join(installdir, "bin", filename)
                    os.ln(file, path.join(installdir, "bin", filename))

                    -- some tools like CMake will try to run moc.exe, trick them
                    os.rm(targetpath .. ".exe")
                    os.ln(file, path.join(installdir, "bin", filename .. ".exe"))
                end
            end
        end
    end)

    on_test(function (package)
        local qt = assert(package:data("qt"))
        os.vrun(path.join(qt.bindir, "moc") .. " -v")
        os.vrun(path.join(qt.bindir, "rcc") .. " -v")
    end)
