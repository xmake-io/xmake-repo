package("wgpu-native")
    set_homepage("https://github.com/gfx-rs/wgpu-native")
    set_description("Native WebGPU implementation based on wgpu-core")
    set_license("Apache-2.0")

    if is_plat("windows") and is_arch("x64") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version).zip", {version = function(version)
            local build = version:ge("v24.0.0+1") and "-msvc" or ""
            return version:gsub("%+", ".") .. "/wgpu-windows-x86_64" .. build .. "-release"
        end})
        add_versions("v27.0.4+0", "f14ca334b4d253881bde2605bd147f332178d705f56fbd74f81458797c77fce1")
        add_versions("v27.0.2+0", "0df0231284cd9ab59dfc382f435caf1275f4372ae0635ef1261d6fe1d58c5a0e")
        add_versions("v25.0.2+1", "e0cdcec5e7601117bb0e457e55d1729199d6f203857c72b432b406493c7434f7")
        add_versions("v24.0.3+1", "72d3abf74e0b55f9474602e2ce7f20fd0f9b9c46be8405b45a697ec1ee343436")
        add_versions("v24.0.0+1", "7dff003da706bc413e514a0395ef369f2935a4dc7c99f61cd97e8fee601c9f8e")
        add_versions("v0.19.4+1", "9e1591d60c2d2ee20d6d4a63bc01c7c5eecf7734761673160aa639e550a1ba4d")
        add_versions("v0.17.0+2", "1b8ae05bb7626e037ab7088f9f11fc8bb8341a32800d33857c09ff2fb1b3893f")
    elseif is_plat("windows") and is_arch("x86") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version).zip", {version = function(version)
            local build = version:ge("v24.0.0+1") and "-msvc" or ""
            return version:gsub("%+", ".") .. "/wgpu-windows-i686" .. build .. "-release"
        end})
        add_versions("v27.0.4+0", "23399f2c9743a2c5396a146a02d8f5dc34b018c7c8826367d172d7a58cea7036")
        add_versions("v27.0.2+0", "542fe3a3e88e617acad2f34d129f0203132b6b175af015cba977dfbee75ccbff")
        add_versions("v25.0.2+1", "0ed7711ded45228ba63405a61746a6b8443b7f257d284726281129850a9ef41d")
        add_versions("v24.0.3+1", "226e196ba4b65a29a1f08e236ad53787f066e4677a8e62382af5a049d07787b2")
        add_versions("v24.0.0+1", "88c82813fa5a737dc9c84a3ce7b8e848bf305b6d6e3679f059aa9694e364c761")
        add_versions("v0.19.4+1", "6bd7d57d132282adf46150e7fb176d86fe6ffd10aa833ad2e70d9dfbe17700df")
        add_versions("v0.17.0+2", "098037ca18c1a3fbf25f061f822762d5eab1cd4ecf8e7d039f9ccbd357322a54")
    elseif is_plat("windows") and is_arch("arm64") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version)/wgpu-windows-aarch64-msvc-release.zip", {version = function(version) return version:gsub("%+", ".") end})
        add_versions("v27.0.4+0", "71271c3671bbcbb8935211dc18bfc1f765326d72f6d1710c93afb0d597000aa9")
        add_versions("v27.0.2+0", "85510bebf7c8c8183b7fd508994b34cc2762612e9c534689dea62b6e30d7d76f")
        add_versions("v25.0.2+1", "039ad9033ae43f478697a7090e16dc9a9b87f171288ff3d0c9f1a41ed10f4e59")
        add_versions("v24.0.3+1", "b2adb3c0e7ffaccb9373b1b4156892dcec6b40778b06d88fb4d62fa386676881")
        add_versions("v24.0.0+1", "0cfc9023dbc2f0ff3ec2b219907b1dd7b46ad83c9a2089e5300ae925ad40664d")
    elseif is_plat("mingw") and is_arch("x86_64") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version)/wgpu-windows-x86_64-gnu-release.zip", {version = function(version) return version:gsub("%+", ".") end})
        add_versions("v27.0.4+0", "c0c2dbcef3c6a9933a1a1bf7cbdaaebed61a33c833bacb0269662f91536be8bd")
        add_versions("v27.0.2+0", "7ff026f39b79d2c48c696c4a21ebb86f7a12634f8921205a27a55ebdbc89567e")
        add_versions("v25.0.2+1", "29eef7a49b0906fef2fe103cf34c7f325b4e53591e16d362d633d0b5994de6be")
        add_versions("v24.0.3+1", "fb3efad0ca05c2eda61ee54349709f05ff28290308b4b80b01f1bad574ce19f7")
        add_versions("v24.0.0+1", "830d9c7d7324f0f3ffb0c71fbbb21549b347f06a5eb5f2802aaa12c809d40fd6")
    elseif is_plat("linux") and is_arch("x86_64") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version)/wgpu-linux-x86_64-release.zip", {version = function(version) return version:gsub("%+", ".") end})
        add_versions("v27.0.4+0", "271481ef76fbf3ea09631a6079e9493636ecf813cd9c92306c44a1a452991ba1")
        add_versions("v27.0.2+0", "4264ba136c0ea3b654f756ba34320f7d868d41716bb8cb7d36ccad4a2c48cdb2")
        add_versions("v25.0.2+1", "74ea0fed0aadc9b353b56db812081a1620d1d72003d7592c449ca39d5f5b61bb")
        add_versions("v24.0.3+1", "86f3eb9f74d7f1ac82ee52d9b2ab15e366ef86a932759c750b7472652836ee59")
        add_versions("v24.0.0+1", "b2169ee4587431f7b1754100115b419795f6155d6163a5de9d0659840fed306b")
        add_versions("v0.19.4+1", "7d73bd7af2be60b632e5ab814996acb381d1b459975d6629f91c468049c8866a")
        add_versions("v0.17.0+2", "2bfebb48072cafee316fcec452d49d02aa46d7096325097e637c3c2e784eca5b")
    elseif is_plat("linux") and is_arch("arm64") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version).zip", {version = function(version)
            local arch = version:ge("v24.0.0+1") and "aarch64" or "x86_64"
            return version:gsub("%+", ".") .. "/wgpu-linux-" .. arch .. "-release"
        end})
        add_versions("v27.0.4+0", "a2f22248200997b69373273b10d50a58164f6ed840877289f3e46bff317b134e")
        add_versions("v27.0.2+0", "76f1f493716d5e67b80c08850471f2ac6d1a45cb694d68c8e56537ed115d29f0")
        add_versions("v25.0.2+1", "ab048ddfcd0274d09c62db793b7dde39f1e8dc8a1135ecfbe2fe102f5cfa9943")
        add_versions("v24.0.3+1", "97786f622d6d4f9aaa87c27d165de8db65daf1d391e0bcc32a2dd9bb45fcd299")
        add_versions("v24.0.0+1", "430007015d6d6560bebf676236a315ccd46a740e628e6b4d777c349edcfdd329")
        add_versions("v0.19.4+1", "6e53aa3f0aec4b2b65cb0d7635000cf39bddd672bcb6138a593bf8cb8134f621")
    elseif is_plat("macosx") and is_arch("x86_64") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version)/wgpu-macos-x86_64-release.zip", {version = function(version) return version:gsub("%+", ".") end})
        add_versions("v27.0.4+0", "660fe9be59b555ec1d7c839e5cf8b6c71762938af61ab444a7a58dd87970dba2")
        add_versions("v27.0.2+0", "e2a2951d087d51f902d764bb667f67460f26f57f8fe2d7c834d819b91b893525")
        add_versions("v25.0.2+1", "64df075f30a7714daf49fa21728e5a3554c5a5254ea6372da5e7b790bc60903c")
        add_versions("v24.0.3+1", "1fbc6930e2811b7fde7f046e5300ae5dc20c451d0c3e42a10ff71efae1f565ac")
        add_versions("v24.0.0+1", "d617f0aed8a70c69a8d3c683b1c1c3c6e60f5c7179cb2ad10df8c8ce5c905948")
        add_versions("v0.19.4+1", "e41a35bf4f2b1c7dd87092cfcb932b7a96118971129a6213b7be240deb07e614")
        add_versions("v0.17.0+2", "749683e616659b5fa9a42151b7b71c2308e114c0322df78975d486aaf43650e9")
    elseif is_plat("macosx") and is_arch("arm64") then
        add_urls("https://github.com/gfx-rs/wgpu-native/releases/download/$(version).zip", {version = function(version)
            local arch = version:ge("v0.18.1+3") and "aarch64" or "arm64"
            return version:gsub("%+", ".") .. "/wgpu-macos-" .. arch .. "-release"
        end})
        add_versions("v27.0.4+0", "15367c26fdbe6892db35007d39f3883593384e777360b70e6bd704cb5dedde53")
        add_versions("v27.0.2+0", "5233eea32720936c0757d8fd91ca2fb5336f4c90297d76541b2975146df50876")
        add_versions("v25.0.2+1", "df4f35417047e0f88ed6facd2cfa42d7a88bdc367bf1c7aa10c462bc8b3a2117")
        add_versions("v24.0.3+1", "f140ff27234ebfa9fcca2b492d0cb499f2e197424b9edc45134bcbad0f8d3a78")
        add_versions("v24.0.0+1", "1c5669dc7d62dfb7e9d740a05fb59b9c9ae366be46229152e50b3c42b91b2384")
        add_versions("v0.19.4+1", "21cf8e69a4a775ea63f437f170a93e371df0f72c83119c81c25a668611c1771d")
        add_versions("v0.17.0+2", "9af5dadcd05fa8d47d37cf171abae65c7d813123d0a60f0b50392da381279d04")
    end

    if is_plat("windows") then
        add_configs("runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})
    end

    add_includedirs("include", "include/webgpu")

    if on_check then
        on_check(function (package)
            if package:is_plat("mingw") and not package:is_arch("x86_64") then
                raise("package(wgpu-native): not saupport platform")
            end
        end)
    end

    on_load("windows", "mingw", function (package)
        if not package:config("shared") then
            package:add("syslinks", "advapi32", "bcrypt", "d3dcompiler", "ntdll", "user32", "userenv", "ws2_32", "gdi32", "opengl32", "propsys", "oleaut32", "ole32", "runtimeobject")
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
            package:add("frameworks", "Metal", "QuartzCore", "Foundation")
        end
    end)

    on_install("windows", "mingw", "linux", "macosx", function (package)
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
        elseif package:is_plat("mingw") then
            if package:config("shared") then
                os.cp(lib_path .. "wgpu_native.dll", package:installdir("lib"))
                os.cp(lib_path .. "libwgpu_native.dll.a", package:installdir("lib"))
            else
                os.cp(lib_path .. "libwgpu_native.a", package:installdir("lib"))
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
