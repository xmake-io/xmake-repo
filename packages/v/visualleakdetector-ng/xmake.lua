package("visualleakdetector-ng")

    set_homepage("https://github.com/GermanAizek/VisualLeakDetector-NG/")
    set_description("Updated vlc plugin for Visual Studio 2010/12/13/15/17/19/22 memory leak detection")

    add_urls("https://github.com/GermanAizek/VisualLeakDetector-NG.git")
    add_versions("2024.05.22", "ba12663d06a08a01bd388d5b4207d0495d793cd3")

    add_configs("shared", {description = "Download shared binaries.", default = true, type = "boolean", readonly=true})

    on_install("windows", function (package)
        local configs = {"vld_vs16.sln"}
        table.insert(configs, "/p:Configuration=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "/p:Platform=" .. (package:is_arch("x64") and "x64" or "Win32"))
        table.insert(configs, "-t:vld")
        import("package.tools.msbuild").build(package, configs)
        os.cp("src/*.h", package:installdir("include"))
        os.cp("setup/dbghelp/" .. (package:is_arch("x64") and "x64" or "x86") .. "/*", package:installdir("bin"))
        local outputdir = path.join("src","bin", package:is_arch("x64") and "x64" or "Win32", (package:debug() and "Debug" or "Release-") .. "*")
        os.cp(outputdir .. "/*.lib", package:installdir("lib"))
        os.cp(outputdir .. "/*.dll", package:installdir("bin"))
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("VLDDisable", {includes = "vld.h", configs = {defines = "VLD_FORCE_ENABLE"}}))
    end)
