package("dotnet")

    set_homepage("https://dotnet.microsoft.com/")
    set_description(".NET is the free, open-source, cross-platform framework for building modern apps and powerful cloud services.")

    if is_host("windows") then
        if is_arch("x64") then
            set_urls("https://download.visualstudio.microsoft.com/download/pr/e2f99985-b54a-43a2-85cf-cfc9a1e0a307/171339e000ade0b6e10c3cb010ed45ba/dotnet-sdk-7.0.202-win-x64.zip")
            add_versions("7.0.202", "1cc74b279cffe42f757b3adeeeec87e351f0fb806016167ffb6b3842d4d6bcd5")
        else
            set_urls("https://download.visualstudio.microsoft.com/download/pr/c7213e17-4955-4fae-a405-1b7101086daf/71963248a7de64c4b00219a8199e7429/dotnet-sdk-7.0.202-win-x86.zip")
            add_versions("7.0.202", "8541bc89a12dac90ba1d6a7c1b6875b9314fc8af04602210be07daa16cfd5e9a")
        end
    elseif is_host("linux") then
        if is_arch("x64", "x86_64") then
            set_urls("https://download.visualstudio.microsoft.com/download/pr/bda88810-e1a6-4cf0-8139-7fd7fe7b2c7a/7a9ffa3e12e5f1c3d8b640e326c1eb14/dotnet-sdk-7.0.202-linux-x64.tar.gz")
            add_versions("7.0.202", "405f15e437582be260460f48eda9dfe613fd87b2557667f20d6ecfa34b09c221")
        elseif is_arch("arm64", "arm64-v8a") then
            set_urls("https://download.visualstudio.microsoft.com/download/pr/c1fd11b0-186a-4aa1-a578-bb1b6613886e/b67e1c9d6d90b1c99b23935273921fa1/dotnet-sdk-7.0.202-linux-arm64.tar.gz")
            add_versions("7.0.202", "5a5d29f3f7515f6df888047eeb9571a2fa06b728a97e30536b1473d2abce0b32")
        end
    elseif is_host("macosx") then
        if is_arch("x64", "x86_64") then
            set_urls("https://download.visualstudio.microsoft.com/download/pr/d3fe9043-0ff4-4584-aacf-1ad41c47407b/7b84ed341359488cd0de21de1b4df6d0/dotnet-sdk-7.0.202-osx-x64.tar.gz")
            add_versions("7.0.202", "1531bfa7bf384f8b5c433d87af170f7839b130ea9c20b617aaf41742a13eefa9")
        elseif is_arch("arm64") then
            set_urls("https://download.visualstudio.microsoft.com/download/pr/4402413a-ef81-4732-a0c0-38f11694b226/e205b8bf48d95902a6dbe1c3cccca272/dotnet-sdk-7.0.202-osx-arm64.tar.gz")
            add_versions("7.0.202", "7f8201d42d31d6985288d0e31a32aa3b1dff40fceb8cb202993c0b72883bcebb")
        end
    end

    on_install("windows|x86", "windows|x64", "linux|x64", "linux|x86_64", "linux|arm64", "linux|arm64-v8a", "macosx|x86_64", "macosx|x64", "macosx|arm64", function (package)

        local out_path = "packs"
        if package:is_plat("windows") then
            out_path = path.join(out_path, "Microsoft.NETCore.App.Host.win-" .. (package:is_arch("x64") and "x64" or "x86"), "7.0.4", "runtimes", "win-" .. (package:is_arch("x64") and "x64" or "x86"), "native")
            
            os.cp(path.join(out_path, "nethost.dll"), package:installdir("bin"))
            os.cp(path.join(out_path, "nethost.lib"), package:installdir("lib"))
        elseif package:is_plat("linux") then
            local is_arm = package:is_arch("arm64", "arm64-v8a")
            out_path = path.join(out_path, "Microsoft.NETCore.App.Host.linux-" .. (is_arm and "arm64" or "x64"), "7.0.4", "runtimes", "linux-" .. (is_arm and "arm64" or "x64"), "native")

            if package:config("shared") then
                os.cp(path.join(out_path, "*.so"), package:installdir("lib"))
            else
                os.cp(path.join(out_path, "*.a"), package:installdir("lib"))
            end
        elseif package:is_plat("macosx") then
            out_path = path.join(out_path, "Microsoft.NETCore.App.Host.osx-" .. (package:is_arch("arm64") and "arm64" or "x64"), "7.0.4", "runtimes", "osx-" .. (package:is_arch("arm64") and "arm64" or "x64"), "native")

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
