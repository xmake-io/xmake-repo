package("qtbase")
    set_kind("template")
    set_homepage("https://www.qt.io")
    set_description("Qt is the faster, smarter way to create innovative devices, modern UIs & applications for multiple screens. Cross-platform software development at its best.")
    set_license("LGPL-3")

    add_configs("shared", {description = "Download shared binaries.", default = true, type = "boolean", readonly = true})
    add_configs("runtimes", {description = "Set compiler runtimes.", default = "MD", readonly = true})
    add_configs("exact_version", {description = "Require exact version match if Qt is system-installed.", default = false, type = "boolean"})
    add_configs("tools_only", {description = "Install only SDK tools, primarily for cross-compilation scenarios.", default = false, type = "boolean"})

    add_deps("aqt")

    if on_check then
        on_check(function (package)
            local version = package:version()
            -- Chech for 32bits support removal in Qt6
            if package:is_plat("windows", "mingw") and version then
                if version:ge("6.0") and package:is_arch("x86", "i386") then
                    raise("package(qt6base): 32bits support was removed in Qt6")
                end
            end
            -- Check for Visual Studio version requirements
            if package:is_plat("windows") and version then
                local vs = package:toolchain("msvc"):config("vs")
                if version:ge("6.8") and tonumber(vs) < 2022 then
                    raise("package(qt6base): Qt 6.8+ requires Visual Studio 2022")
                elseif version:ge("6.0") and tonumber(vs) < 2019 then
                    raise("package(qt6base): Qt 6.0+ requires Visual Studio 2019")
                end
            end
            -- Check for symbolic link creation issues when cross-compiling on Windows
            if is_host("windows") and package:is_plat("linux") then
                wprint("It seems that you are installing Qt SDK on Windows for a non-Windows platform. If you encounter issues related to symbolic link creation, " ..
                       "please try enabling Developer Mode in Windows Settings or run xmake with administrator privileges.")
            end
            -- Check for WASM support
            if package:is_plat("wasm") and version then
                -- For more information on WASM support, visit:
                -- https://doc.qt.io/qt-6/wasm.html
                -- https://aqtinstall.readthedocs.io/en/latest/getting_started.html#installing-qt-for-wasm
                if version:ge("6.8") then
                    -- TODO: Update this check when aqtinstall supports Qt 6.8+ for WASM
                    raise("package(qt6base): Qt 6.8+ for WASM is not supported by aqtinstall yet")
                elseif (version:ge("6.0") and version:lt("6.2")) or version:lt("5.13") then
                    raise("package(qtbase): WASM support requires Qt 5.13+ or Qt 6.2+")
                end
            end
            -- Check for ARM64 support
            if package:is_arch("arm64.*", "aarch64") and package:is_plat("windows", "mingw", "linux") and version then
                if package:is_plat("windows", "mingw") and version:lt("6.8") then
                    raise("package(qt6base): Windows on ARM64 support was added in Qt 6.8")
                elseif package:is_plat("linux") and version:lt("6.7") then
                    raise("package(qt6base): Linux on ARM64 support was added in Qt 6.7")
                end
            end
        end)
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
        if package:is_cross() then
            local host_qt_depname = "qt-tools"
            if package:version() then
                host_qt_depname = host_qt_depname .. " " .. package:version():shortstr()
            end
            package:add("deps", host_qt_depname, {configs = {tools_only = true, exact_version = true}})
        end
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

        local qt
        local version = package:version()
        local find_opt = {force = opt.force}
        if package:config("exact_version") and version then
            find_opt.version = version:shortstr()
        end
        if not package:is_cross() then
            qt = find_qt(sdkdir, find_opt)
        else
            local host_qt = package:dep("qt-tools")
            if not host_qt then
                return
            end
            local host_qt_data = host_qt:data("qt") or find_qt(nil, {version = host_qt:version() and host_qt:version():shortstr()})
            if not host_qt_data then
                return
            end
            qt = find_qt(sdkdir, table.join(find_opt, {sdkdir_host = host_qt_data.sdkdir}))
            if qt then
                -- Avoid mistakenly identifying "host_qt" as the target SDK
                if host_qt_data.sdkdir and host_qt_data.sdkdir == qt.sdkdir then
                    return
                end
            end
        end
        if not qt then
            return
        end

        local qtversion = semver.new(qt.sdkver)
        if version and not qtversion:eq(version) then
            if package:config("exact_version") or not qtversion:ge(version) then
                return
            end
        end
        qt.version = qt.sdkver
        package:data_set("qt", qt)
        return qt
    end)

    on_install(function (package)
        import("core.base.semver")
        import("core.project.config")
        import("core.tool.toolchain")

        local version = package:version()
        local versionstr = version:shortstr()

        -- Usage of `aqtinstall`: aqt install-qt <host> <target> <Qt version> [<arch>]
        -- <host> options: {linux, linux_arm64, mac, windows, windows_arm64}
        -- <target> options: {desktop, winrt, android, ios}
        --
        -- The `pseudo_host` variable (used as <host>) is determined based on the target platform
        --
        -- Behavior:
        -- 1. No cross-compilation (package:plat() == os.host()):
        --    - Downloads Qt libraries and SDK tools specific to the host platform.
        --
        -- 2. Cross-compilation (package:plat() ~= os.host()):
        --    - Downloads Qt libraries and incompatible SDK tools.
        --    - Usable SDK tools are retrieved from package:dep("qt-tools") or the "qt_host" configuration.

        local pseudo_host
        local platform_map = {windows = "windows", mingw = "windows", linux = "linux", macosx = "mac"}
        if package:is_plat("windows", "mingw", "linux", "macosx") then
            pseudo_host = platform_map[package:plat()]
        elseif package:is_plat("android") then
            pseudo_host = platform_map[os.host()]
        elseif package:is_plat("iphoneos") then
            pseudo_host = "mac"
        elseif package:is_plat("wasm") then
            if version:ge("6.8") then
                pseudo_host = "all_os"
            else
                pseudo_host = platform_map[os.host()]
            end
        else
            raise("unhandled platform " .. package:plat())
        end
        if package:is_arch("arm64.*", "aarch64") and package:is_plat("windows", "mingw", "linux") then
            pseudo_host = pseudo_host .. "_arm64"
        end

        local target
        if package:is_plat("windows", "mingw", "linux", "macosx") then
            target = "desktop"
        elseif package:is_plat("android") then
            target = "android"
        elseif package:is_plat("iphoneos") then
            target = "ios"
        elseif package:is_plat("wasm") then
            if version:ge("6.8") then
                target = "wasm"
            else
                target = "desktop"
            end
        else
            raise("unhandled plat " .. package:plat())
        end

        local arch
        if package:is_plat("windows", "mingw") then
            local winarch
            if package:is_arch("x64", "x86_64", "arm64") then
                winarch = "64"
            elseif version:lt("6.0") and package:is_arch("x86", "i386") then -- 32bits support was removed in Qt6
                winarch = "32"
            else
                raise("unhandled arch " .. package:targetarch())
            end

            local compiler_version
            if package:is_plat("windows") then
                local vs = package:toolchain("msvc"):config("vs")
                if version:ge("6.8") then
                    compiler_version = "msvc2022"
                elseif tonumber(vs) >= 2019 and version:ge("5.15") then
                    compiler_version = "msvc2019"
                elseif tonumber(vs) >= 2017 then
                    compiler_version = "msvc2017"
                elseif tonumber(vs) >= 2015 then
                    compiler_version = "msvc2015"
                else
                    raise("unhandled msvc version " .. vs)
                end

                if package:is_arch("x64", "x86_64") then
                    compiler_version = compiler_version .. "_64"
                elseif package:is_arch("arm64") then -- arm64 support was added in Qt6.2
                    compiler_version = compiler_version .. "_arm64"
                end
            else
                local cc = package:tool("cc")
                local ccversion = os.iorunv(cc, {"-dumpversion"}):trim()
                local mingw_version = semver.new(ccversion)
                if version:ge("6.2.2") then
                    compiler_version = "mingw"
                elseif mingw_version:ge("8.1") then
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
            if package:is_arch("arm64.*", "aarch64") then
                arch = "linux_gcc_arm64"
            elseif version:ge("6.7.0") then
                arch = "linux_gcc_64"
            else
                arch = "gcc_64"
            end
        elseif package:is_plat("macosx") then
            arch = "clang_64"
        elseif package:is_plat("android") then
            if version:le("5.13") or version:ge("6.0") then
                if package:is_arch("x86_64", "x64") then
                    arch = "android_x86_64"
                elseif package:is_arch("arm64", "arm64-v8a") then
                    arch = "android_arm64_v8a"
                elseif package:is_arch("armv7", "armv7-a", "armeabi", "armeabi-v7a") then
                    arch = "android_armv7"
                elseif package:is_arch("x86") then
                    arch = "android_x86"
                else
                    raise("unhandled arch " .. package:targetarch())
                end
            else
                arch = "android"
            end
        elseif package:is_plat("iphoneos") then
            arch = "ios"
        elseif package:is_plat("wasm") then
            if version:lt("6.5") then
                arch = "wasm_32"
            else
                arch = "wasm_multithread" -- "wasm_singlethread" is also available as an option.
            end
        end

        local installdir = package:installdir()
        local aqt_args = {"install-qt", "-O", installdir, pseudo_host, target, versionstr, arch}

        if package:config("tools_only") then
            -- Attempt to reduce the installation size by specifying only the required archives
            local archives = {
                "qtbase",        -- For qmake, moc, rcc, uic, windeployqt, androiddeployqt
                "qttools",       -- For lupdate, lrelease
                "qtdeclarative"  -- For qml
            }
            if is_host("linux") then
                table.join2(archives, {"icu"})
            end
            local available_archives = try {
                function()
                    return os.iorunv("aqt", {"list-qt", pseudo_host, target, "--archives", versionstr, arch}):split(" ")
                end
            } or {}
            local specify_archives = true
            for _, archive in ipairs(archives) do
                if not table.contains(available_archives, archive) then
                    specify_archives = false
                    break
                end
            end
            if specify_archives then
                table.insert(aqt_args, "--archives")
                table.join2(aqt_args, archives)
            end
        end

        os.vrunv("aqt", aqt_args)

        -- move files to root
        os.mv(path.join(installdir, versionstr, "*", "*"), installdir)
        os.rmdir(path.join(installdir, versionstr))

    end)

    on_test(function (package)
        import("lib.detect.find_file")

        local qt = assert(package:data("qt"))

        local search_dirs = {}
        if qt.bindir_host then table.insert(search_dirs, qt.bindir_host) end
        if qt.bindir then table.insert(search_dirs, qt.bindir) end
        if qt.libexecdir_host then table.insert(search_dirs, qt.libexecdir_host) end
        if qt.libexecdir then table.insert(search_dirs, qt.libexecdir) end

        local function getbin(name)
            name = name .. (is_host("windows") and ".exe" or "")
            return assert(find_file(name, search_dirs), name .. " not found!")
        end

        os.vrun(getbin("qmake") .. " -v")
        os.vrun(getbin("moc") .. " -v")
        -- rcc -v and uic -v seems to hang CI forever
        --os.vrun(getbin("rcc") .. " -v") -- rcc -v hangs CI 
        --os.vrun(getbin("uic") .. " -v") -- uic -v seems to hang on CI
    end)
