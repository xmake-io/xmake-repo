package("wgpu-native")
    set_homepage("https://github.com/gfx-rs/wgpu-native")
    set_description("Native WebGPU implementation based on wgpu-core")
    set_license("Apache-2.0")

    if is_plat("windows") and is_arch("x64") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version)/wgpu-windows-x86_64-release.zip", {version = function(version) return version:gsub("%+", ".") end})
        add_versions("v0.17.0+2", "1b8ae05bb7626e037ab7088f9f11fc8bb8341a32800d33857c09ff2fb1b3893f")
    elseif is_plat("windows") and is_arch("x86") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version)/wgpu-windows-i686-release.zip", {version = function(version) return version:gsub("%+", ".") end})
        add_versions("v0.17.0+2", "098037ca18c1a3fbf25f061f822762d5eab1cd4ecf8e7d039f9ccbd357322a54")
    elseif is_plat("linux") and is_arch("x86_64") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version)/wgpu-linux-x86_64-release.zip", {version = function(version) return version:gsub("%+", ".") end})
        add_versions("v0.17.0+2", "2bfebb48072cafee316fcec452d49d02aa46d7096325097e637c3c2e784eca5b")
    elseif is_plat("macosx") and is_arch("x86_64") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version)/wgpu-macos-x86_64-release.zip", {version = function(version) return version:gsub("%+", ".") end})
        add_versions("v0.17.0+2", "749683e616659b5fa9a42151b7b71c2308e114c0322df78975d486aaf43650e9")
    elseif is_plat("macosx") and is_arch("arm64") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version)/wgpu-macos-arm64-release.zip", {version = function(version) return version:gsub("%+", ".") end})
        add_versions("v0.17.0+2", "9af5dadcd05fa8d47d37cf171abae65c7d813123d0a60f0b50392da381279d04")
    end

    if is_plat("windows") then
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})
    end

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("syslinks", "Advapi32", "bcrypt", "d3dcompiler", "NtDll", "User32", "Userenv", "WS2_32")
        end
    end)

    on_load("macosx", function (package)
        if not package:config("shared") then
            package:add("syslinks", "objc")
            package:add("frameworks", "Metal")
        end
    end)

    on_install("windows|x64", "windows|x86", "linux|x86_64", "macosx|x86_64", "macosx|arm64", function (package)
        os.cp("*.h", package:installdir("include"))
        if package:is_plat("windows") then
            if package:config("shared") then
                os.cp("wgpu_native.dll", package:installdir("bin"))
                os.cp("wgpu_native.pdb", package:installdir("bin"))
                os.cp("wgpu_native.dll.lib", package:installdir("lib"))
            else
                os.cp("wgpu_native.lib", package:installdir("lib"))
            end
        elseif package:is_plat("linux") then
            if package:config("shared") then
                os.cp("libwgpu_native.so", package:installdir("bin"))
            else
                os.cp("libwgpu_native.a", package:installdir("lib"))
            end
        elseif package:is_plat("macosx") then
            if package:config("shared") then
                os.cp("libwgpu_native.dylib", package:installdir("bin"))
            else
                os.cp("libwgpu_native.a", package:installdir("lib"))
            end
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("wgpuCreateInstance", {includes = "wgpu.h"}))
    end)
