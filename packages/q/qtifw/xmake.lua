package("qtifw")
    set_kind("binary")
    set_homepage("https://doc.qt.io/qtinstallerframework/")
    set_description("The Qt Installer Framework provides a set of tools and utilities to create installers for the supported desktop Qt platforms: Linux, Microsoft Windows, and macOS.")
    set_license("GPL-3")

    add_versions("4.6.0", "dummy")

    add_deps("aqt")

    on_fetch(function (package, opt)
        if opt.system then
            return import("lib.detect.find_tool")("binarycreator", {check = "--help"})
        end
    end)

    on_install("@windows", "@msys", "@macosx", function (package)

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

        local target = "desktop"
        local version = package:version()
        local installdir = package:installdir()
	local qtifw_version = "qt.tools.ifw." .. version:major() .. version:minor()
	if is_host("windows") then
            os.vrunv("aqt", {"install-tool", "-O", installdir, host, target, "tools_ifw", qtifw_version, "--external", "7z"})
        else
            os.vrunv("aqt", {"install-tool", "-O", installdir, host, target, "tools_ifw", qtifw_version})
        end
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
