package("vld")

    set_homepage("https://github.com/oneiric/vld")
    set_description("Visual Leak Detector for Visual C++")

    add_urls("https://github.com/oneiric/vld/archive/refs/tags/v$(version).zip")
    add_versions("2.7.0", "1bb5695a424b234d29d16acdc6bdb4be79d58501674b6d3765a19f237c5ad0f2")

    add_configs("shared", {description = "Download shared binaries.", default = true, type = "boolean", readonly=true})

    on_install("windows", function (package)
        io.replace("src/tests/basics/Allocs.cpp", "#error Unsupported compiler", '#define CRTDLLNAME   _T("ucrtbase.dll")', {plain=true})
        io.replace("src/tests/suite/testsuite.cpp", "#error Unsupported compiler", '#define CRTDLLNAME   _T("ucrtbase.dll")', {plain=true})
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
