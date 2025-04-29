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

    on_install("windows", function (package)
        import("package.tools.msbuild")
        os.cp("Public/easyhook.h", package:installdir("include"))
        local arch = package:is_arch("x64") and "x64" or "Win32"
        if package:is_arch("arm64") then
            arch = "ARM64"
            io.replace("EasyHook.sln", "|x64", "|ARM64", {plain = true})
            io.replace("EasyHookDll/EasyHookDll.vcxproj", "|x64", "|ARM64", {plain = true})
        end
        if not package:has_runtime("MT", "MTd") then
            -- Allow MD, MDd
            io.replace("EasyHookDll/EasyHookDll.vcxproj", "MultiThreadedDebug", "MultiThreadedDebugDLL", {plain = true})
            io.replace("EasyHookDll/EasyHookDll.vcxproj", "MultiThreaded", "MultiThreadedDLL", {plain = true})
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
