package("easyhook")
    set_homepage("https://easyhook.github.io")
    set_description("EasyHook - The reinvention of Windows API Hooking")
    set_license("MIT")

    add_urls("https://github.com/EasyHook/EasyHook/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return version:gsub("%+", ".")
    end})
    add_urls("https://github.com/EasyHook/EasyHook.git")

    add_versions("v2.7.7097+0", "d0a9f0026c2939234d6cb086a64234ad90ff5eb574fc09dd5d6e0b32e72221d1")
    add_patches("v2.7.7097+0", "patches/v2.7.7097+0/fix-build.patch", "b11b0dd74a224f23530ba1b8fe3c210d62f946868a67d0a07afba5501d572abb")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    add_syslinks("psapi", "Aux_ulib")

    on_install("windows|!arm*", function (package)
        import("package.tools.msbuild")
        -- Debundle
        os.rm("EasyHookDll/AUX_ULIB_x64.LIB", "EasyHookDll/AUX_ULIB_x86.LIB")
        io.replace("EasyHookDll/EasyHookDll.vcxproj", "Aux_ulib_x86.lib", "Aux_ulib.lib", {plain = true})
        io.replace("EasyHookDll/EasyHookDll.vcxproj", "Aux_ulib_x64.lib", "Aux_ulib.lib", {plain = true})
        os.cp("Public/easyhook.h", package:installdir("include"))
        local arch = package:is_arch("x64") and "x64" or "Win32"
        if not package:has_runtime("MT", "MTd") then
            -- Allow MD, MDd
            io.replace("EasyHookDll/EasyHookDll.vcxproj",
                "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>", "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>", {plain = true})
            io.replace("EasyHookDll/EasyHookDll.vcxproj",
                "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>", "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>", {plain = true})
        end
        local mode = package:is_debug() and "netfx4-Debug" or "netfx4-Release"
        local configs = { "EasyHook.sln" }
        table.insert(configs, "/t:EasyHookDll")
        table.insert(configs, "/p:Configuration=" .. mode)
        table.insert(configs, "/p:Platform=" .. arch)
        table.insert(configs, "/p:BuildProjectReferences=false")
        msbuild.build(package, configs)
        os.cp("Build/*/*/**.lib", package:installdir("lib"))
        os.cp("Build/*/*/**.dll", package:installdir("bin"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("LhUpdateModuleInformation", {includes = "easyhook.h"}))
    end)
