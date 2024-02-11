package("dotnet")

    set_homepage("https://dotnet.microsoft.com/")
    set_description(".NET is the free, open-source, cross-platform framework for building modern apps and powerful cloud services.")

    if is_host("windows") then
        if is_arch("x64") then
            local versions = {
                ["7.0.202"] = "e2f99985-b54a-43a2-85cf-cfc9a1e0a307/171339e000ade0b6e10c3cb010ed45ba/dotnet-sdk-7.0.202-win-x64", 
                ["7.0.405"] = "2133b143-9c4f-4daa-99b0-34fa6035d67b/193ede446d922eb833f1bfe0239be3fc/dotnet-sdk-7.0.405-win-x64", 
                ["8.0.101"] = "6902745c-34bd-4d66-8e84-d5b61a17dfb7/e61732b00f7e144e162d7e6914291f16/dotnet-sdk-8.0.101-win-x64"
            }
            set_urls("https://download.visualstudio.microsoft.com/download/pr/$(version).zip", {version = function (version)
                return versions[tostring(version)]
            end})
        
            add_versions("7.0.202", "1cc74b279cffe42f757b3adeeeec87e351f0fb806016167ffb6b3842d4d6bcd5")
            add_versions("7.0.405", "a158307a32caee886e24a2cc5114c3fba230f8c6173a1b707dc112ff377607b7")
            add_versions("8.0.101", "2fa8eb34ce5a03a6fc606b35cfd6ff1d1ac36dfd35a4772d6a6ec1939de46244")
        else
            local versions = {
                ["7.0.202"] = "c7213e17-4955-4fae-a405-1b7101086daf/71963248a7de64c4b00219a8199e7429/dotnet-sdk-7.0.202-win-x86", 
                ["7.0.405"] = "bf8a63f5-f029-4d0a-8027-975284829ad0/e1fb2ba0532d63c6cec0fb04987a91bf/dotnet-sdk-7.0.405-win-x86", 
                ["8.0.101"] = "059613f3-d3e9-4585-b8a9-3814e675b6d0/01150dbaaa7f392f103137bd325786b6/dotnet-sdk-8.0.101-win-x86"
            }
            set_urls("https://download.visualstudio.microsoft.com/download/pr/$(version).zip", {version = function (version)
                return versions[tostring(version)]
            end})
        
            add_versions("7.0.202", "8541bc89a12dac90ba1d6a7c1b6875b9314fc8af04602210be07daa16cfd5e9a")
            add_versions("7.0.405", "77907f8db16228b04421bb8c63e89fa2c6d7e728c1e5cd0187b87d4aafa0acc0")
            add_versions("8.0.101", "af9feebee04bc25ac2a0f98dc37c8808da4a9c7586c55de8aafafab2d2ad8b98")
        end
    elseif is_host("linux") then
        if is_arch("x64", "x86_64") then
            local versions = {
                ["7.0.202"] = "bda88810-e1a6-4cf0-8139-7fd7fe7b2c7a/7a9ffa3e12e5f1c3d8b640e326c1eb14/dotnet-sdk-7.0.202-linux-x64", 
                ["7.0.405"] = "5202b091-2406-445c-b40a-68a5b97c882b/b509f2a7a0eb61aea145b990b40b6d5b/dotnet-sdk-7.0.405-linux-x64", 
                ["8.0.101"] = "9454f7dc-b98e-4a64-a96d-4eb08c7b6e66/da76f9c6bc4276332b587b771243ae34/dotnet-sdk-8.0.101-linux-x64"
            }
            set_urls("https://download.visualstudio.microsoft.com/download/pr/$(version).tar.gz", {version = function (version)
                return versions[tostring(version)]
            end})
        
            add_versions("7.0.202", "405f15e437582be260460f48eda9dfe613fd87b2557667f20d6ecfa34b09c221")
            add_versions("7.0.405", "db1f6226039313ceda561de803298fc6df0a0f34e1b214629225bb20e2c03e90")
            add_versions("8.0.101", "3c61ffcee8947e0ead6196799d058e671b00bc6b983983f2bde5d29f702de2fe")
        elseif is_arch("arm64", "arm64-v8a") then
            local versions = {
                ["7.0.202"] = "c1fd11b0-186a-4aa1-a578-bb1b6613886e/b67e1c9d6d90b1c99b23935273921fa1/dotnet-sdk-7.0.202-linux-arm64", 
                ["7.0.405"] = "bdfe4e91-3a24-421f-881a-47b6d91404cb/cfe786933a6a7fd358b799af23542827/dotnet-sdk-7.0.405-linux-arm64", 
                ["8.0.101"] = "092bec24-9cad-421d-9b43-458b3a7549aa/84280dbd1eef750f9ed1625339235c22/dotnet-sdk-8.0.101-linux-arm64"
            }
            set_urls("https://download.visualstudio.microsoft.com/download/pr/$(version).tar.gz", {version = function (version)
                return versions[tostring(version)]
            end})
        
            add_versions("7.0.202", "5a5d29f3f7515f6df888047eeb9571a2fa06b728a97e30536b1473d2abce0b32")
            add_versions("7.0.405", "83b18606c055b528856ad5642828627542d339510f33155ff126bb2522a5c68d")
            add_versions("8.0.101", "6e6d9c0d20e9b87247638eff4e66eccf04078ca956cecb9be53f155f44a2c508")
        end
    elseif is_host("macosx") then
        if is_arch("x64", "x86_64") then
            local versions = {
                ["7.0.202"] = "d3fe9043-0ff4-4584-aacf-1ad41c47407b/7b84ed341359488cd0de21de1b4df6d0/dotnet-sdk-7.0.202-osx-x64", 
                ["7.0.405"] = "77e1c2df-aaa1-44aa-abc5-ffca44b1dfc9/1fea5228f09398a885ca956d1b537f02/dotnet-sdk-7.0.405-osx-x64", 
                ["8.0.101"] = "c7f806d2-1483-4a52-893a-4de1054b0bff/a6f52ed50876c45f859192b6576a14d5/dotnet-sdk-8.0.101-osx-x64"
            }
            set_urls("https://download.visualstudio.microsoft.com/download/pr/$(version).tar.gz", {version = function (version)
                return versions[tostring(version)]
            end})
        
            add_versions("7.0.202", "1531bfa7bf384f8b5c433d87af170f7839b130ea9c20b617aaf41742a13eefa9")
            add_versions("7.0.405", "f8ff3c54f633e3f8dc0208c97b43a6ad53442a6139dbb11e6957129a7a20bf79")
            add_versions("8.0.101", "cad53a19dd0ad86c814bbf24f8449e068ffbc3749a285e41b7b6e6004fa3881f")
        elseif is_arch("arm64") then
            local versions = {
                ["7.0.202"] = "4402413a-ef81-4732-a0c0-38f11694b226/e205b8bf48d95902a6dbe1c3cccca272/dotnet-sdk-7.0.202-osx-arm64", 
                ["7.0.405"] = "5bb0e0e4-2a8d-4aba-88ad-232e1f65c281/ee6d35f762d81965b4cf336edde1b318/dotnet-sdk-7.0.405-osx-arm64", 
                ["8.0.101"] = "ef083c06-7aee-4a4f-b18b-50c9a8990753/e206864e7910e81bbd9cb7e674ff1b4c/dotnet-sdk-8.0.101-osx-arm64"
            }
            set_urls("https://download.visualstudio.microsoft.com/download/pr/$(version).tar.gz", {version = function (version)
                return versions[tostring(version)]
            end})
        
            add_versions("7.0.202", "7f8201d42d31d6985288d0e31a32aa3b1dff40fceb8cb202993c0b72883bcebb")
            add_versions("7.0.405", "b1b822bc2e7041f7ed6708ec8a41d417f6fa1c962b051681cf36a91d6929fefa")
            add_versions("8.0.101", "aa56166e43f19ab9a71bf1203a9028920f2f555d985f8f1fe0ed0fe221b109bd")
        end
    end

    on_install("windows|x86", "windows|x64", "linux|x64", "linux|x86_64", "linux|arm64", "linux|arm64-v8a", "macosx|x86_64", "macosx|x64", "macosx|arm64", function (package)

        -- The division by 100 is intentional...
        print(package:version():patch())
        local version_str = package:version():major() .. "." .. package:version():minor() .. "." .. package:version():patch()[1]
        local out_path = "packs"
        if package:is_plat("windows") then
            out_path = path.join(out_path, "Microsoft.NETCore.App.Host.win-" .. (package:is_arch("x64") and "x64" or "x86"), version_str, "runtimes", "win-" .. (package:is_arch("x64") and "x64" or "x86"), "native")
            
            os.cp(path.join(out_path, "nethost.dll"), package:installdir("bin"))
            os.cp(path.join(out_path, "nethost.lib"), package:installdir("lib"))
        elseif package:is_plat("linux") then
            local is_arm = package:is_arch("arm64", "arm64-v8a")
            out_path = path.join(out_path, "Microsoft.NETCore.App.Host.linux-" .. (is_arm and "arm64" or "x64"), version_str, "runtimes", "linux-" .. (is_arm and "arm64" or "x64"), "native")

            if package:config("shared") then
                os.cp(path.join(out_path, "*.so"), package:installdir("lib"))
            else
                os.cp(path.join(out_path, "*.a"), package:installdir("lib"))
            end
        elseif package:is_plat("macosx") then
            out_path = path.join(out_path, "Microsoft.NETCore.App.Host.osx-" .. (package:is_arch("arm64") and "arm64" or "x64"), version_str, "runtimes", "osx-" .. (package:is_arch("arm64") and "arm64" or "x64"), "native")

            if package:config("shared") then
                os.cp(path.join(out_path, "*.dylib"), package:installdir("lib"))
            else
                os.cp(path.join(out_path, "*.a"), package:installdir("lib"))
            end
        end

        os.cp(path.join(out_path, "*.h"), package:installdir("include"))
        package:add("links", "nethost")
        
    end)

    on_test(function (package)
        assert(package:has_cfuncs("get_hostfxr_path", {includes = "nethost.h"}))
    end)
