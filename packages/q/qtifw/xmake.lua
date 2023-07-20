package("qtifw")
    set_kind("binary")
    set_homepage("https://doc.qt.io/qtinstallerframework/")
    set_description("The Qt Installer Framework provides a set of tools and utilities to create installers for the supported desktop Qt platforms: Linux, Microsoft Windows, and macOS.")
    set_license("GPL-3")

    if is_host("linux") then
        add_deps("xcb-util-wm")
        add_deps("xcb-util-image")
        add_deps("xcb-util-keysyms")
    end
    add_deps("aqt")

    on_install("linux,windows,macosx,mingw,msys@linux,windows,macosx,msys", function (package)
        import("core.base.semver")
        import("core.project.config")
        import("core.tool.toolchain")

        local host
        if is_host("windows", "msys") then
            host = "windows"
        elseif is_host("linux") then
            host = "linux"
        elseif is_host("macosx") then
            host = "mac"
        else
            raise("unhandled host " .. os.host())
        end

        local target
        if package:is_plat("windows", "mingw", "msys", "linux", "macosx") then
            target = "desktop"
        else
            raise("unhandled plat " .. package:plat())
        end

        local version = package:version() or semver.new("4.6.0")
        local installdir = package:installdir()
        os.vrunv("aqt", {"install-tool", "-O", installdir, host, target, "tools_ifw", "qt.tools.ifw." .. version:major() .. version:minor()})
        os.mv(path.join(installdir, "Tools", "*", version:major() .. "." .. version:minor(), "*"), installdir)
        os.rmdir(path.join(installdir, "Tools"))
    end)

    on_test(function (package)
        local function assertbin(name)
            if is_host("windows") then
                name = name .. ".exe"
            end
            local exec = path.join(package:installdir(), "bin", name)
            assert(os.isexec(exec), name .. " not found!")
        end
        os.vrun("binarycreator --help")
        os.vrun("archivegen --help")
        os.vrun("devtool --help")
        assertbin("repogen")
    end)
