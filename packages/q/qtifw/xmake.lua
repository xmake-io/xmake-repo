package("qtifw")
    set_kind("binary")
    set_homepage("https://doc.qt.io/qtinstallerframework/")
    set_description("The Qt Installer Framework provides a set of tools and utilities to create installers for the supported desktop Qt platforms: Linux, Microsoft Windows, and macOS.")
    set_license("GPL-3")

    add_deps("aqt")

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install(function (package)
        import("core.base.semver")
        import("core.project.config")
        import("core.tool.toolchain")

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

        local versionstr = package:version()
        if versionstr == "latest" then
            versionstr = "4.6.0"
        elseif versionstr == nil then
            versionstr = "4.6.0"
        end
        local version = semver.new(versionstr)

        local installdir = package:installdir()
        os.vrunv("aqt", {"install-tool", "-O", installdir, host, target, "tools_ifw", "qt.tools.ifw." .. version:major() .. version:minor()})

        -- move files to root
        os.mv(path.join(installdir, "Tools", "*", version:major() .. "." .. version:minor(), "*"), installdir)
        os.rmdir(path.join(installdir, "Tools"))
    end)

    on_test(function (package)

        local function getbin(name)
            if is_host("windows") then
                name = name .. ".exe"
            end
            local exec = path.join(package:installdir(), "bin", name)
            assert(os.isexec(exec), name .. " not found!")
            return exec
        end

        os.vrun(getbin("binarycreator") .. " --help")
        os.vrun(getbin("archivegen") .. " --help")
        os.vrun(getbin("devtools") .. " --help")
        getbin("repogen")
    end)
