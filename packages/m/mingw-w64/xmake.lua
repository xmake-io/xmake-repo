package("mingw-w64")

    set_kind("toolchain")
    set_homepage("https://sourceforge.net/projects/mingw-w64/")
    set_description("The mingw-w64 project is a complete runtime environment for gcc to support binaries native to Windows 64-bit and 32-bit operating systems.")

    if is_arch("x86") then
        local filenames = {
            ["11.2.0"] = "11.2.0-rt_v9-rev1/i686-11.2.0-release-posix-sjlj-rt_v9-rev1",
            ["15.2.0"] = "15.2.0-rt_v13-rev0/i686-15.2.0-release-posix-dwarf-ucrt-rt_v13-rev0"
        }
        add_urls("https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/mingw-builds/$(version)/threads-posix/sjlj/i686-$(version)-release-posix-sjlj-rt_v6-rev0.7z", {alias = "sourceforge"})
        add_urls("https://github.com/niXman/mingw-builds-binaries/releases/download/$(version).7z", {alias = "github", version = function(version) return filenames[tostring(version)] end})
        add_versions("sourceforge:8.1.0", "f5b97d1a8c15f527c0f0397d0f128ff0af6acc9fab1ecd79ad403661c0a425ac")
        add_versions("github:11.2.0", "578fe0ffce6110cbff56b4028d10d6e5fdb61e3aa2d02dc71bd4230c56096ef5")
        add_versions("github:15.2.0", "8559c1e27c48f139400b4d7da848ca30a7bdb9f1fbe06e241b1b53baa6149d2a")
    else
        local filenames = {
            ["11.2.0"] = "11.2.0-rt_v9-rev1/x86_64-11.2.0-release-posix-seh-rt_v9-rev1",
            ["15.2.0"] = "15.2.0-rt_v13-rev0/x86_64-15.2.0-release-posix-seh-ucrt-rt_v13-rev0"
        }
        add_urls("https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/$(version)/threads-posix/seh/x86_64-$(version)-release-posix-seh-rt_v6-rev0.7z", {alias = "sourceforge"})
        add_urls("https://github.com/niXman/mingw-builds-binaries/releases/download/$(version).7z", {alias = "github", version = function(version) return filenames[tostring(version)] end})
        add_versions("sourceforge:8.1.0", "853970527b5de4a55ec8ca4d3fd732c00ae1c69974cc930c82604396d43e79f8")
        add_versions("github:11.2.0", "2c943b1a9231ce09f227b0c8fc6cabc61da3581f4ef2f7682f9393f5a1d70ae8")
        add_versions("github:15.2.0", "05b3361a3a3e20a5789db37fc2bb6a70d0b02e4667b5a31d9a6672ea40d22c69")
    end

    add_configs("python2", {description = "Export builtin python2.", default = false, type = "boolean"})

    on_fetch("@windows", function (package, opt)
        if opt.system then
            local mingw = import("detect.sdks.find_mingw")()
            if mingw then
                package:addenv("PATH", mingw.bindir)
                return mingw
            end
        end
    end)

    on_install("@windows", function (package)
        os.cp("*", package:installdir())
        if package:config("python2") then
            package:addenv("PATH", path.join("opt", "bin"))
        end
    end)

    on_test(function (package)
        os.vrun("gcc -v")
        os.vrun("gfortran -v")
        if package:config("python2") then
            os.vrun("python2 --version")
        end
    end)
