package("mingw-w64")

    set_kind("toolchain")
    set_homepage("https://sourceforge.net/projects/mingw-w64/")
    set_description("The mingw-w64 project is a complete runtime environment for gcc to support binaries native to Windows 64-bit and 32-bit operating systems.")

    if is_arch("x86") then
        add_urls("https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/mingw-builds/$(version)/threads-posix/sjlj/i686-$(version)-release-posix-sjlj-rt_v6-rev0.7z")
        add_versions("8.1.0", "f5b97d1a8c15f527c0f0397d0f128ff0af6acc9fab1ecd79ad403661c0a425ac")
    else
        add_urls("https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/$(version)/threads-posix/seh/x86_64-$(version)-release-posix-seh-rt_v6-rev0.7z")
        add_versions("8.1.0", "853970527b5de4a55ec8ca4d3fd732c00ae1c69974cc930c82604396d43e79f8")
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
