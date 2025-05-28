package("uasm")
    set_kind("binary")
    set_homepage("http://www.terraspace.co.uk/uasm.html")
    set_description("UASM - Macro Assembler")

    add_urls("https://github.com/Terraspace/UASM/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Terraspace/UASM.git")

    add_versions("v2.57r", "09fa69445f2af47551e82819d024e6b4b629fcfd47af4a22ccffbf37714230e5")

    on_install("windows", function (package)
        import("package.tools.msbuild")
        local arch = package:is_arch("x64") and "x64" or "Win32"
        if package:is_arch("arm64") then
            arch = "ARM64"
            io.replace("UASM.sln", "|x64", "|ARM64", {plain = true})
        end
        local mode = package:is_debug() and "Debug" or "Release"
        local configs = { "UASM.sln" }
        table.insert(configs, "/p:Configuration=" .. mode)
        table.insert(configs, "/p:Platform=" .. arch)
        if package:is_arch("arm64") then
            io.replace("UASM.vcxproj", "|x64", "|ARM64", {plain = true})
            io.replace("UASM.vcxproj", "<Platform>x64", "<Platform>ARM64", {plain = true})
        end
        if package:has_runtime("MT", "MTd") then
            -- Allow MT, MTd
            io.replace("UASM.vcxproj", "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>", "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>", {plain = true})
            io.replace("UASM.vcxproj", "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>", "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>", {plain = true})
        end
        io.replace("UASM.vcxproj", [[<Command>regress\runtestsVS.cmd</Command>]], [[]], {plain = true})
        msbuild.build(package, configs)
        os.cp("*/*/UASM.exe", path.join(package:installdir("bin"), "uasm.exe"))
    end)

    on_test(function (package)
        os.vrun("uasm -h")
    end)
