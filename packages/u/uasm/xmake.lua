package("uasm")
    set_kind("binary")
    set_homepage("http://www.terraspace.co.uk/uasm.html")
    set_description("UASM - Macro Assembler")

    add_urls("https://github.com/Terraspace/UASM/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Terraspace/UASM.git")

    add_versions("v213", "e6b75408d80f4ddc68412a51b2b42bb0db860a8adaaa76c29bd166bacf76875f")
    add_versions("v2.57r", "09fa69445f2af47551e82819d024e6b4b629fcfd47af4a22ccffbf37714230e5")

    if not is_plat("windows") then
        add_patches("v2.57r", "patches/fix-bool.diff", "91a6b4634fab3fb3991a372c845247bd895ea3d2de104d3687eb6e2c61e44e39")
        add_patches("v2.57r", "patches/fix-build.diff", "840a36bf7200941cd98331245a5b7b71f9ee56a912b4c10c255498c6f7c89d45")
        add_patches("v2.57r", "patches/fix-esc-seq.diff", "4011194c59f87b5be798b4e85dca869e3a3f7ddf2b0fc4f8b3b26190df1abca3")
        add_patches("v2.57r", "patches/uint64-fix.diff", "ea6bab7192894fc673b55b9ead67cf1eb0046cd34c425f33781e167097988662")
    end

    on_install("macosx", function (package)
        os.cp(path.join(package:scriptdir(), "ports", "osx64.mak"), "osx64.mak")
        local configs = { "-f", "osx64.mak", "CC=clang"}
        import("package.tools.make").install(package, configs)
        os.cp("GccUnixR/uasm", path.join(package:installdir("bin"), "uasm"))
    end)

    on_install("msys", "mingw@macosx,linux,windows,msys", function (package)
        local configs = { "-f", "Makefile-DOS-GCC.mak", "CC=gcc -c -IH -std=gnu11 -funsigned-char -fcommon -Wno-implicit-function-declaration -Wno-incompatible-pointer-types"}
        import("package.tools.make").install(package, configs)
        os.cp("*/hjwasm.exe", path.join(package:installdir("bin"), "uasm.exe"))
    end)

    on_install("@windows", function (package)
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
