package("wgpu-native")
    set_homepage("https://github.com/gfx-rs/wgpu-native")
    set_description("Native WebGPU implementation based on wgpu-core")
    set_license("Apache-2.0")

    if is_plat("windows") and is_arch("x64") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version).zip", {version = function(version)
            local build = version:ge("v24.0.0+1") and "-msvc" or ""
            return version:gsub("%+", ".") .. "/wgpu-windows-x86_64" .. build .. "-release"
        end})
        add_versions("v24.0.0+1", "7dff003da706bc413e514a0395ef369f2935a4dc7c99f61cd97e8fee601c9f8e")
        add_versions("v0.19.4+1", "9e1591d60c2d2ee20d6d4a63bc01c7c5eecf7734761673160aa639e550a1ba4d")
        add_versions("v0.17.0+2", "1b8ae05bb7626e037ab7088f9f11fc8bb8341a32800d33857c09ff2fb1b3893f")
    elseif is_plat("windows") and is_arch("x86") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version).zip", {version = function(version)
            local build = version:ge("v24.0.0+1") and "-msvc" or ""
            return version:gsub("%+", ".") .. "/wgpu-windows-i686" .. build .. "-release"
        end})
        add_versions("v24.0.0+1", "88c82813fa5a737dc9c84a3ce7b8e848bf305b6d6e3679f059aa9694e364c761")
        add_versions("v0.19.4+1", "6bd7d57d132282adf46150e7fb176d86fe6ffd10aa833ad2e70d9dfbe17700df")
        add_versions("v0.17.0+2", "098037ca18c1a3fbf25f061f822762d5eab1cd4ecf8e7d039f9ccbd357322a54")
    elseif is_plat("windows") and is_arch("arm64") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version)/wgpu-windows-aarch64-msvc-release.zip", {version = function(version) return version:gsub("%+", ".") end})
        add_versions("v24.0.0+1", "0cfc9023dbc2f0ff3ec2b219907b1dd7b46ad83c9a2089e5300ae925ad40664d")
    elseif is_plat("linux") and is_arch("x86_64") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version)/wgpu-linux-x86_64-release.zip", {version = function(version) return version:gsub("%+", ".") end})
        add_versions("v24.0.0+1", "b2169ee4587431f7b1754100115b419795f6155d6163a5de9d0659840fed306b")
        add_versions("v0.19.4+1", "7d73bd7af2be60b632e5ab814996acb381d1b459975d6629f91c468049c8866a")
        add_versions("v0.17.0+2", "2bfebb48072cafee316fcec452d49d02aa46d7096325097e637c3c2e784eca5b")
    elseif is_plat("linux") and is_arch("arm64") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version).zip", {version = function(version)
            local arch = version:ge("v24.0.0+1") and "aarch64" or "x86_64"
            return version:gsub("%+", ".") .. "/wgpu-windows-" .. arch .. "-release"
        end})
        add_versions("v24.0.0+1", "430007015d6d6560bebf676236a315ccd46a740e628e6b4d777c349edcfdd329")
        add_versions("v0.19.4+1", "6e53aa3f0aec4b2b65cb0d7635000cf39bddd672bcb6138a593bf8cb8134f621")
    elseif is_plat("macosx") and is_arch("x86_64") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version)/wgpu-macos-x86_64-release.zip", {version = function(version) return version:gsub("%+", ".") end})
        add_versions("v24.0.0+1", "d617f0aed8a70c69a8d3c683b1c1c3c6e60f5c7179cb2ad10df8c8ce5c905948")
        add_versions("v0.19.4+1", "e41a35bf4f2b1c7dd87092cfcb932b7a96118971129a6213b7be240deb07e614")
        add_versions("v0.17.0+2", "749683e616659b5fa9a42151b7b71c2308e114c0322df78975d486aaf43650e9")
    elseif is_plat("macosx") and is_arch("arm64") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version).zip", {version = function(version)
            local arch = version:ge("v0.18.1+3") and "aarch64" or "arm64"
            return version:gsub("%+", ".") .. "/wgpu-macos-" .. arch .. "-release"
        end})
        add_versions("v24.0.0+1", "1c5669dc7d62dfb7e9d740a05fb59b9c9ae366be46229152e50b3c42b91b2384")
        add_versions("v0.19.4+1", "21cf8e69a4a775ea63f437f170a93e371df0f72c83119c81c25a668611c1771d")
        add_versions("v0.17.0+2", "9af5dadcd05fa8d47d37cf171abae65c7d813123d0a60f0b50392da381279d04")
    end

    if is_plat("windows") then
        add_configs("runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})
    end

    add_includedirs("include", "include/webgpu")

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("syslinks", "Advapi32", "bcrypt", "d3dcompiler", "NtDll", "User32", "Userenv", "WS2_32", "Gdi32", "Opengl32", "propsys", "OleAut32", "Ole32", "RuntimeObject")
        end
    end)

    on_load("linux", function (package)
        if not package:config("shared") then
            package:add("syslinks", "dl", "pthread")
        end
    end)

    on_load("macosx", function (package)
        if not package:config("shared") then
            package:add("syslinks", "objc")
            package:add("frameworks", "Metal", "QuartzCore")
        end
    end)

    on_install("windows|x64", "windows|x86", "windows|arm64", "linux|arm64", "linux|x86_64", "macosx|x86_64", "macosx|arm64", function (package)
        os.cp("**.h", package:installdir("include", "webgpu"))
        local lib_path = ""
        if os.exists("lib") then
            lib_path = "lib/"
        end

        if package:is_plat("windows") then
            if package:config("shared") then
                os.cp(lib_path .. "wgpu_native.dll", package:installdir("lib"))
                os.cp(lib_path .. "wgpu_native.pdb", package:installdir("lib"))
                os.cp(lib_path .. "wgpu_native.dll.lib", package:installdir("lib"))
            else
                os.cp(lib_path .. "wgpu_native.lib", package:installdir("lib"))
            end
        elseif package:is_plat("linux") then
            if package:config("shared") then
                os.cp(lib_path .. "libwgpu_native.so", package:installdir("lib"))
            else
                os.cp(lib_path .. "libwgpu_native.a", package:installdir("lib"))
            end
        elseif package:is_plat("macosx") then
            if package:config("shared") then
                os.cp(lib_path .. "libwgpu_native.dylib", package:installdir("lib"))
            else
                os.cp(lib_path .. "libwgpu_native.a", package:installdir("lib"))
            end
        end
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <wgpu.h>
            #include <stddef.h>
            void test()
            {
                WGPUInstance instance = wgpuCreateInstance(NULL);
                if(instance != NULL)
                    wgpuInstanceRelease(instance);
            }
        ]]}))
    end)
