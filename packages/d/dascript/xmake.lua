package("dascript")
    set_homepage("https://github.com/GaijinEntertainment/daScript")
    set_description("Daslang - high-performance statically strongly typed programming language")
    set_license("BSD-3-Clause")
    -- TODO : add compilation from source for old linux systems 
    if is_host("windows") then
        if is_arch("x64", "x86_64") then
            add_urls("https://github.com/GaijinEntertainment/daScript/releases/download/v0.5.9.2.1/daslang-bundle-windows-x86_64.zip")
            add_versions("0.5.9.2.1", "9ea32c7f0aee2c84fe5d652b627964c74772422f1e0fde235536d72936669f60")
        elseif is_arch("x86", "i386") then
            add_urls("https://github.com/GaijinEntertainment/daScript/releases/download/v0.5.9.2.1/daslang-bundle-windows-x86.zip")
            add_versions("0.5.9.2.1", "f6545b310c73463334b31625adc3587cf4930ef71fcee1caf0fe0b35df1df313")
        else
            raise("package(dascript 0.5.9.2.1): Windows architecture %s is unsupported", os.arch())
        end
    elseif is_host("macosx") then
        if is_arch("arm64") then
            add_urls("https://github.com/GaijinEntertainment/daScript/releases/download/v0.5.9.2.1/daslang-bundle-darwin26-arm64.zip")
            add_versions("0.5.9.2.1", "b8ba4943cf4aa0e0042918ae2f1511935029a149488d4835b56679f390747faa")
        elseif is_arch("x86_64") then
            add_urls("https://github.com/GaijinEntertainment/daScript/releases/download/v0.5.9.2.1/daslang-bundle-darwin15-x86_64.zip")
            add_versions("0.5.9.2.1", "5130b9867cd9cc7b24fc3baf6218c563ffe01bfea5e95170748a95a44379d431")
        else
            raise("package(dascript 0.5.9.2.1): MacOS architecture %s is unsupported", os.arch())
        end
    elseif is_host("linux") then
        if is_arch("arm64", "aarch64") then
            add_urls("https://github.com/GaijinEntertainment/daScript/releases/download/v0.5.9.2.1/daslang-bundle-linux-arm64.zip")
            add_versions("0.5.9.2.1", "23595d99a62279d4f2b9e50c7b47f9c46f6a7bd02dd2ce2a7e01e422021b1775")
        elseif is_arch("x86_64", "x64") then
            add_urls("https://github.com/GaijinEntertainment/daScript/releases/download/v0.5.9.2.1/daslang-bundle-linux-x86_64.zip")
            add_versions("0.5.9.2.1", "7ca9c700d72097e14678aa9ae33bb15ebc98abf14c8d1fd9e9e89692d5513898")
        else
            raise("package(dascript 0.5.9.2.1): Linux architecture %s is unsupported", os.arch())
        end
    else
        raise("package(dascript 0.5.9.2.1): Unsupported host platform %s", os.host())
    end

    on_install("windows", "linux", "macosx", function (package)
        os.cp("daslang_bundle/bin", package:installdir())
        os.cp("daslang_bundle/lib", package:installdir())
        os.cp("daslang_bundle/exemples",package:installdir())
        os.cp("daslang_bundle/modules",package:installdir())
        if not package:is_plat("windows") then
            os.vrunv("chmod", {"+x", package:installdir("bin/daslang")})
        end
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        local name = "daslang"
        if package:is_plat("windows") then
            name = "daslang.exe"
        end
        os.runv(package:installdir("bin", name), {"--version"})
    end)
