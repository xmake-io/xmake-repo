package("dotnet")

    set_homepage("https://dotnet.microsoft.com/")
    set_description(".NET is the free, open-source, cross-platform framework for building modern apps and powerful cloud services.")

    if is_host("windows") then
        if is_arch("x64") then
            local versions = {
                ["7.0.4"] = "e2f99985-b54a-43a2-85cf-cfc9a1e0a307/171339e000ade0b6e10c3cb010ed45ba/dotnet-sdk-7.0.202-win-x64",
                ["7.0.15"] = "2133b143-9c4f-4daa-99b0-34fa6035d67b/193ede446d922eb833f1bfe0239be3fc/dotnet-sdk-7.0.405-win-x64",
                ["8.0.1"] = "6902745c-34bd-4d66-8e84-d5b61a17dfb7/e61732b00f7e144e162d7e6914291f16/dotnet-sdk-8.0.101-win-x64",
                ["8.0.6"] = "7ac2d880-2d57-4008-850e-4b42b829c354/e1c92cb3b6a85f53cab6fa55b14b49e3/dotnet-sdk-8.0.301-win-x64",
                ["9.0.3"] = "a16e9966-3076-4d6d-914e-6b8228444876/123e08ddbdf6da335a3b636e66375c87/dotnet-sdk-9.0.202-win-x64"
            }
            set_urls("https://download.visualstudio.microsoft.com/download/pr/$(version).zip", {version = function (version)
                return versions[tostring(version)]
            end})

            add_versions("7.0.4", "1cc74b279cffe42f757b3adeeeec87e351f0fb806016167ffb6b3842d4d6bcd5")
            add_versions("7.0.15", "a158307a32caee886e24a2cc5114c3fba230f8c6173a1b707dc112ff377607b7")
            add_versions("8.0.1", "2fa8eb34ce5a03a6fc606b35cfd6ff1d1ac36dfd35a4772d6a6ec1939de46244")
            add_versions("8.0.6", "eb32b4332b10ad526ad64f58a6e904d16855e49bb38c51c863033c53ecea4a7d")
            add_versions("9.0.3", "d1dda520f8eb602e0b447e92d92d14145f37aa28ab59b267f6d8fc692051ec77")
        elseif is_arch("arm64") then
            local versions = {
                ["7.0.4"] = "h52f31250-1961-4203-9f51-9b9afce0db15/129915360a0e0e6ee59e895efd389b0a/dotnet-sdk-7.0.202-win-arm64",
                ["7.0.15"] = "5079d3e3-3fa9-4ffa-92fc-bbf17e2d3543/634299784e4c6f7a1f5b06cf5070d505/dotnet-sdk-7.0.405-win-arm64",
                ["8.0.1"] = "bfcfe7c7-d722-45b0-80df-663516a401ce/d7b91a51df647c710c96cde20aa8b100/dotnet-sdk-8.0.101-win-arm64",
                ["8.0.6"] = "90961c76-55e1-406c-80b5-440306ac50cb/337ad62c9692c3e74e4e2b209f3a85f6/dotnet-sdk-8.0.301-win-arm64",
                ["9.0.3"] = "31f2d59e-c4a9-4439-a248-cbf04a645713/0c5e22648cd7673cfc4c8bf308903d02/dotnet-sdk-9.0.202-win-arm64"
            }
            set_urls("https://download.visualstudio.microsoft.com/download/pr/$(version).zip", {version = function (version)
                return versions[tostring(version)]
            end})

            add_versions("7.0.4", "5b2d8d381fc52379d25f5ccfa0882476b6003060682abf19fd96151a08d4298b")
            add_versions("7.0.15", "272156f0cfc4752eaae580196eb0f3287c1c758c99a116a70062a2083cafa0bd")
            add_versions("8.0.1", "feca0648fa200fd19ea3cb00266a76488d76880243b5c57bf9ecf9d91892ddfe")
            add_versions("8.0.6", "9e77515ecc64e4a891109cc5da2a7bf57f4d534e0654b36636ada9bae79e487a")
            add_versions("9.0.3", "08a10fc80c3d09ff046d4436baf6985049136b59ce1cc5971436f0606eec893f")
        else
            local versions = {
                ["7.0.4"] = "c7213e17-4955-4fae-a405-1b7101086daf/71963248a7de64c4b00219a8199e7429/dotnet-sdk-7.0.202-win-x86",
                ["7.0.15"] = "bf8a63f5-f029-4d0a-8027-975284829ad0/e1fb2ba0532d63c6cec0fb04987a91bf/dotnet-sdk-7.0.405-win-x86",
                ["8.0.1"] = "059613f3-d3e9-4585-b8a9-3814e675b6d0/01150dbaaa7f392f103137bd325786b6/dotnet-sdk-8.0.101-win-x86",
                ["8.0.6"] = "8ffefb00-26bf-4dc0-bfd3-82003b4f122e/05aad9cf85a8456cdbe08b2b59da866e/dotnet-sdk-8.0.301-win-x86",
                ["9.0.3"] = "39a7dd23-5db8-4421-a404-25ceed8289b0/413a8a323454453b4af73cadfc77a0ff/dotnet-sdk-9.0.202-win-x86"
            }
            set_urls("https://download.visualstudio.microsoft.com/download/pr/$(version).zip", {version = function (version)
                return versions[tostring(version)]
            end})

            add_versions("7.0.4", "8541bc89a12dac90ba1d6a7c1b6875b9314fc8af04602210be07daa16cfd5e9a")
            add_versions("7.0.15", "77907f8db16228b04421bb8c63e89fa2c6d7e728c1e5cd0187b87d4aafa0acc0")
            add_versions("8.0.1", "af9feebee04bc25ac2a0f98dc37c8808da4a9c7586c55de8aafafab2d2ad8b98")
            add_versions("8.0.6", "04029a8f88f395a03497ae4542712eaec6d651f9eb4dc5727143b6c54fa7bda2")
            add_versions("9.0.3", "f9ac07e379874b0968086854bb74dbc8a69288195377c3bd975b946f0d419fed")
        end
    elseif is_host("linux") then
        if is_arch("x64", "x86_64") then
            local versions = {
                ["7.0.4"] = "bda88810-e1a6-4cf0-8139-7fd7fe7b2c7a/7a9ffa3e12e5f1c3d8b640e326c1eb14/dotnet-sdk-7.0.202-linux-x64",
                ["7.0.15"] = "5202b091-2406-445c-b40a-68a5b97c882b/b509f2a7a0eb61aea145b990b40b6d5b/dotnet-sdk-7.0.405-linux-x64",
                ["8.0.1"] = "9454f7dc-b98e-4a64-a96d-4eb08c7b6e66/da76f9c6bc4276332b587b771243ae34/dotnet-sdk-8.0.101-linux-x64",
                ["8.0.6"] = "86497c4f-3dc8-4ee7-9f6a-9e0464059427/293d074c28bbfd9410f4db8e021fa290/dotnet-sdk-8.0.301-linux-x64",
                ["9.0.3"] = "c2220b38-c512-4447-b564-a18048d14327/965cdfe500a937c2d28bc9d2db45cd1f/dotnet-sdk-9.0.202-linux-x64"
            }
            set_urls("https://download.visualstudio.microsoft.com/download/pr/$(version).tar.gz", {version = function (version)
                return versions[tostring(version)]
            end})

            add_versions("7.0.4", "405f15e437582be260460f48eda9dfe613fd87b2557667f20d6ecfa34b09c221")
            add_versions("7.0.15", "db1f6226039313ceda561de803298fc6df0a0f34e1b214629225bb20e2c03e90")
            add_versions("8.0.1", "3c61ffcee8947e0ead6196799d058e671b00bc6b983983f2bde5d29f702de2fe")
            add_versions("8.0.6", "d237cf0e8865f51eb9634df32a8bcfb1dd95dac95c0d16b5d599df867ab16c27")
            add_versions("9.0.3", "0c7bc01debcad57a61fe15bf3c7e6baff1bbbd4f10e4f1284b95866dfff5b444")
        elseif is_arch("arm64", "arm64-v8a") then
            local versions = {
                ["7.0.4"] = "c1fd11b0-186a-4aa1-a578-bb1b6613886e/b67e1c9d6d90b1c99b23935273921fa1/dotnet-sdk-7.0.202-linux-arm64",
                ["7.0.15"] = "bdfe4e91-3a24-421f-881a-47b6d91404cb/cfe786933a6a7fd358b799af23542827/dotnet-sdk-7.0.405-linux-arm64",
                ["8.0.1"] = "092bec24-9cad-421d-9b43-458b3a7549aa/84280dbd1eef750f9ed1625339235c22/dotnet-sdk-8.0.101-linux-arm64",
                ["8.0.6"] = "cd9decc0-f3ef-46d6-b7d1-348b757781ad/9ad92a8f4b805feb3d017731e78eca15/dotnet-sdk-8.0.301-linux-arm64",
                ["9.0.3"] = "52daf653-e6d8-4915-aea1-9c2e2be169a5/9f3e289918eb9054770b69c0b100bb8f/dotnet-sdk-9.0.202-linux-arm64"
            }
            set_urls("https://download.visualstudio.microsoft.com/download/pr/$(version).tar.gz", {version = function (version)
                return versions[tostring(version)]
            end})

            add_versions("7.0.4", "5a5d29f3f7515f6df888047eeb9571a2fa06b728a97e30536b1473d2abce0b32")
            add_versions("7.0.15", "83b18606c055b528856ad5642828627542d339510f33155ff126bb2522a5c68d")
            add_versions("8.0.1", "6e6d9c0d20e9b87247638eff4e66eccf04078ca956cecb9be53f155f44a2c508")
            add_versions("8.0.6", "0e90d60a1759567fcfaf9b9efd1734603493a6ad562e40620e1d2df8ab120f8c")
            add_versions("9.0.3", "e38c65156588446f4686b50607996708a4648f9075efe12d73857473f9e10136")
        end
    elseif is_host("macosx") then
        if is_arch("x64", "x86_64") then
            local versions = {
                ["7.0.4"] = "d3fe9043-0ff4-4584-aacf-1ad41c47407b/7b84ed341359488cd0de21de1b4df6d0/dotnet-sdk-7.0.202-osx-x64",
                ["7.0.15"] = "77e1c2df-aaa1-44aa-abc5-ffca44b1dfc9/1fea5228f09398a885ca956d1b537f02/dotnet-sdk-7.0.405-osx-x64",
                ["8.0.1"] = "c7f806d2-1483-4a52-893a-4de1054b0bff/a6f52ed50876c45f859192b6576a14d5/dotnet-sdk-8.0.101-osx-x64",
                ["8.0.6"] = "6ef47a54-b1c6-4000-8df4-486f64464c2b/ae87b597b19312fa9f73b9f2f8c687bd/dotnet-sdk-8.0.301-osx-x64",
                ["9.0.3"] = "bc0334a2-641c-4e60-b07b-b1f65c05da0f/f1e9820b1ad0ddf0104103cd5d4fe69b/dotnet-sdk-9.0.202-osx-x64"
            }
            set_urls("https://download.visualstudio.microsoft.com/download/pr/$(version).tar.gz", {version = function (version)
                return versions[tostring(version)]
            end})

            add_versions("7.0.4", "1531bfa7bf384f8b5c433d87af170f7839b130ea9c20b617aaf41742a13eefa9")
            add_versions("7.0.15", "f8ff3c54f633e3f8dc0208c97b43a6ad53442a6139dbb11e6957129a7a20bf79")
            add_versions("8.0.1", "cad53a19dd0ad86c814bbf24f8449e068ffbc3749a285e41b7b6e6004fa3881f")
            add_versions("8.0.6", "0bd66f52ddf92efdbed459362fb807b30360a1f854144c84789e12607a35ea75")
            add_versions("9.0.3", "893930d0b256780c8f0a6c0b7a601541e39c568df835f7099fad89ab13057b31")
        elseif is_arch("arm64") then
            local versions = {
                ["7.0.4"] = "4402413a-ef81-4732-a0c0-38f11694b226/e205b8bf48d95902a6dbe1c3cccca272/dotnet-sdk-7.0.202-osx-arm64",
                ["7.0.15"] = "5bb0e0e4-2a8d-4aba-88ad-232e1f65c281/ee6d35f762d81965b4cf336edde1b318/dotnet-sdk-7.0.405-osx-arm64",
                ["8.0.1"] = "ef083c06-7aee-4a4f-b18b-50c9a8990753/e206864e7910e81bbd9cb7e674ff1b4c/dotnet-sdk-8.0.101-osx-arm64",
                ["8.0.6"] = "c503e53c-0567-4604-b7a8-1d6e7a1357f5/53e78f56b01147a092c0cc273b443550/dotnet-sdk-8.0.301-osx-arm64",
                ["9.0.3"] = "98cc1e45-e17c-4e63-afb1-86583dce24fe/948df23085579a4ce3f38620540eb088/dotnet-sdk-9.0.202-osx-arm64"
            }
            set_urls("https://download.visualstudio.microsoft.com/download/pr/$(version).tar.gz", {version = function (version)
                return versions[tostring(version)]
            end})

            add_versions("7.0.4", "7f8201d42d31d6985288d0e31a32aa3b1dff40fceb8cb202993c0b72883bcebb")
            add_versions("7.0.15", "b1b822bc2e7041f7ed6708ec8a41d417f6fa1c962b051681cf36a91d6929fefa")
            add_versions("8.0.1", "aa56166e43f19ab9a71bf1203a9028920f2f555d985f8f1fe0ed0fe221b109bd")
            add_versions("8.0.6", "86a5a398a4f9c093a43687b93ac4c3a487b44e4193cc7155620a37dbc4476b87")
            add_versions("9.0.3", "4deb670a00fcbbaf65bfde9fd777a134cd34f0f1fbb94da048d303311d36ceec")
        end
    end

    on_install("windows|x86", "windows|x64", "windows|arm64", "linux|x64", "linux|x86_64", "linux|arm64", "linux|arm64-v8a", "macosx|x86_64", "macosx|x64", "macosx|arm64", function (package)
        local version_str = package:version_str()
        local out_path = "packs"
        if package:is_plat("windows") then
            local arch = package:is_arch("x64") and "x64" or (package:is_arch("arm64") and "arm64" or "x86")
            out_path = path.join(out_path, "Microsoft.NETCore.App.Host.win-" .. arch, version_str, "runtimes", "win-" .. arch, "native")

            os.cp(path.join(out_path, "nethost.dll"), package:installdir("bin"))
            os.cp(path.join(out_path, "nethost.lib"), package:installdir("lib"))
        elseif package:is_plat("linux") then
            local arch = package:is_arch("arm64", "arm64-v8a") and "arm64" or "x64"
            out_path = path.join(out_path, "Microsoft.NETCore.App.Host.linux-" .. arch, version_str, "runtimes", "linux-" .. arch, "native")

            if package:config("shared") then
                os.cp(path.join(out_path, "*.so"), package:installdir("lib"))
            else
                os.cp(path.join(out_path, "*.a"), package:installdir("lib"))
            end
        elseif package:is_plat("macosx") then
            local arch = package:is_arch("arm64") and "arm64" or "x64"
            out_path = path.join(out_path, "Microsoft.NETCore.App.Host.osx-" .. arch, version_str, "runtimes", "osx-" .. arch, "native")

            if package:config("shared") then
                os.cp(path.join(out_path, "*.dylib"), package:installdir("lib"))
            else
                os.cp(path.join(out_path, "*.a"), package:installdir("lib"))
            end
        end

        os.cp(path.join(out_path, "*.h"), package:installdir("include"))
        package:add("links", "nethost")
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("get_hostfxr_path", {includes = "nethost.h"}))
    end)
