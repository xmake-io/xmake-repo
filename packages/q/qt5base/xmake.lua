package("qt5base")

    set_kind("phony")
    set_homepage("https://www.qt.io")
    set_description("Qt is the faster, smarter way to create innovative devices, modern UIs & applications for multiple screens. Cross-platform software development at its best.")
    set_license("LGPL-3")

    add_configs("shared", {description = "Download shared binaries.", default = true, type = "boolean", readonly = true})
    add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})

    add_versions("5.15.2", "dummy")
    add_versions("5.12.5", "dummy")

    add_deps("aqt", {private=true}) -- only required for installation

    on_fetch(function (package, opt)
        local qt = package:data("qtdir")
        if qt then
            return qt
        end

        if os.isfile(package:manifest_file()) then
            local installdir = package:installdir()
            local qt = {
                version = package:version():shortstr(),
                bindir = path.join(installdir, "bin"),
                includedir = path.join(installdir, "include"),
                libdir = path.join(installdir, "lib")
            }
            package:data_set("qtdir", qt)
            return qt
        end

        if not opt.system then
            return
        end

        import("core.base.semver")
        import("detect.sdks.find_qt")
        local qt = find_qt()
        if not qt then
            return
        end

        local qtversion = semver.new(qt.sdkver)
        if not qtversion:satisfies("5.X") then
            return
        end

        qt.version = qt.sdkversion

        package:data_set("qtdir", qt)
        return qt
    end)

    on_install("windows", "linux", "macosx", "mingw", "android", "iphoneos", function (package)
        local version = package:version() or semver.new("5.15.2")

        local host
        if is_host("windows") then
            host = "windows"
        elseif is_host("linux") then
            host = "linux"
        elseif is_host("macosx") then
            host = "mac"
        else
            os.raise("unhandled host " .. os.host())
        end

        local target
        if package:is_plat("windows", "mingw", "linux", "macosx") then
            target = "desktop"
        elseif package:is_plat("android") then
            target = "android"
        elseif package:is_plat("iphoneos") then
            target = "ios"
        else
            os.raise("unhandled plat " .. package:plat())
        end

        local arch
        if package:is_plat("windows", "mingw") then
            local winArch
            if package:is_targetarch("x64", "x86_64") then
                winArch = "64"
            elseif package:is_targetarch("x86", "i386") then
                winArch = "32"
            else
                os.raise("unhandled arch " .. package:targetarch())
            end

            local compilerVersion
            if package:is_plat("windows") then
                local vs = import("core.tool.toolchain").load("msvc"):config("vs")
                if tonumber(vs) >= 2019 then
                    compilerVersion = "msvc2019"
                elseif vs == "2017" or vs == "2015" then
                    compilerVersion = "msvc" .. vs
                else
                    os.raise("unhandled msvc version " .. vs)
                end

                if package:is_targetarch("x64", "x86_64") then
                    compilerVersion = compilerVersion .. "_64"
                end
            else
                local cc = package:tool("cc")
                local version = os.iorunv(cc, {"-dumpversion"}):trim()

                import("core.base.semver")
                local mingw_version = semver.new(version)

                if mingw_version:ge("8.1") then
                    compilerVersion = "mingw81"
                elseif mingw_version:ge("7.3") then
                    compilerVersion = "mingw73"
                elseif mingw_version:ge("5.3") then
                    compilerVersion = "mingw53"
                else
                    os.raise("unhandled mingw version " .. version)
                end
            end

            arch = "win" .. winArch .. "_" .. compilerVersion
        elseif package:is_plat("linux") then
            arch = "gcc_64"
        elseif package:is_plat("macosx") then
            arch = "clang_64"
        elseif package:is_plat("android") then
            if package:version():le("5.13") then
                if package:is_targetarch("x86_64", "x64") then
                    arch = "android_x86_64"
                elseif package:is_targetarch("arm64", "arm64-v8a") then
                    arch = "android_arm64_v8a"
                elseif package:is_targetarch("armv7", "armv7-a") then
                    arch = "android_armv7"
                elseif package:is_targetarch("x86") then
                    arch = "android_x86"
                end
            else
                arch = "android"
            end
        end

        local installdir = package:installdir()
        os.vrunv("aqt", {"install-qt", "-O", installdir, host, target, version:shortstr(), arch})

        -- move files to root
        local subdirs = {}
        if package:is_plat("linux") then
            table.insert(subdirs, package:is_targetarch("x86_64") and "gcc_64" or "gcc_32")
            table.insert(subdirs, package:is_targetarch("x86_64") and "clang_64" or "clang_32")
        elseif package:is_plat("macosx") then
            table.insert(subdirs, package:is_targetarch("x86_64") and "clang_64" or "clang_32")
        elseif package:is_plat("windows") then
            import("core.project.config")
            local vs = config.get("vs")
            if vs then
                table.insert(subdirs, package:is_targetarch("x64") and "msvc" .. vs .. "_64" or "msvc" .. vs .. "_32")
                table.insert(subdirs, "msvc" .. vs)
            end
            table.insert(subdirs, package:is_targetarch("x64") and "msvc*_64" or "msvc*_32")
            table.insert(subdirs, "msvc*")
        elseif package:is_plat("mingw") then
            table.insert(subdirs, package:is_targetarch("x86_64") and "mingw*_64" or "mingw*_32")
        elseif package:is_plat("android") then
            local subdir
            if package:is_targetarch("arm64-v8a") then
                subdir = "android_arm64_v8a"
            elseif package:is_targetarch("armeabi-v7a", "armeabi", "armv7-a", "armv5te") then -- armv7-a/armv5te are deprecated
                subdir = "android_armv7"
            elseif package:is_targetarch("x86", "i386") then -- i386 is deprecated
                subdir = "android_x86"
            elseif package:is_targetarch("x86_64") then
                subdir = "android_x86_64"
            end
            if subdir then
                table.insert(subdirs, subdir)
            end
            table.insert(subdirs, "android")
        elseif package:is_plat("wasm") then
            table.insert(subdirs, "wasm_32")
        else
            table.insert(subdirs, "*")
        end

        local installeddir
        for _, subdir in pairs(subdirs) do
            local results = os.dirs(path.join(installdir, version, subdir), function (file, isdir) return false end)
            if results and #results > 0 then
                installeddir = results[1]
                break
            end
        end

        if not installeddir then
            os.raise("couldn't find where qt was installed!")
        end

        os.mv(installeddir .. "/*", installdir)
        os.rmdir(path.join(installdir, version))

        package:data_set("qtdir", {
            version = version:shortstr(),
            bindir = path.join(installdir, "bin"),
            includedir = path.join(installdir, "include"),
            libdir = path.join(installdir, "lib")
        })
    end)

    on_test(function (package)
        local qt = assert(package:data("qtdir"))
        os.vrun(path.join(qt.bindir, "moc") .. " -v")
        os.vrun(path.join(qt.bindir, "rcc") .. " -v")
        --os.vrun(path.join(qt.bindir, "uic") .. " -v")
    end)
