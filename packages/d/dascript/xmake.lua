package("dascript")
    set_homepage("https://github.com/GaijinEntertainment/daScript")
    set_description("Daslang - high-performance statically strongly typed programming language")
    set_license("BSD-3-Clause")

    if is_host("windows") then
        if is_arch("x64", "x86_64") then
            add_urls("https://github.com/GaijinEntertainment/daScript/releases/download/$(version)/daslang-bundle-windows-x86_64.zip", {version = function (version) return version:gsub("%+", ".") end})
            add_versions("v0.5.9+2.1", "9ea32c7f0aee2c84fe5d652b627964c74772422f1e0fde235536d72936669f60")
        elseif is_arch("x86", "i386") then
            add_urls("https://github.com/GaijinEntertainment/daScript/releases/download/$(version)/daslang-bundle-windows-x86.zip", {version = function (version) return version:gsub("%+", ".") end})
            add_versions("v0.5.9+2.1", "f6545b310c73463334b31625adc3587cf4930ef71fcee1caf0fe0b35df1df313")
        end
    elseif is_host("macosx") then
        if is_arch("arm64") then
            add_urls("https://github.com/GaijinEntertainment/daScript/releases/download/$(version)/daslang-bundle-darwin26-arm64.zip", {version = function (version) return version:gsub("%+", ".") end})
            add_versions("v0.5.9+2.1", "b8ba4943cf4aa0e0042918ae2f1511935029a149488d4835b56679f390747faa")
        elseif is_arch("x86_64") then
            add_urls("https://github.com/GaijinEntertainment/daScript/releases/download/$(version)/daslang-bundle-darwin15-x86_64.zip", {version = function (version) return version:gsub("%+", ".") end})
            add_versions("v0.5.9+2.1", "5130b9867cd9cc7b24fc3baf6218c563ffe01bfea5e95170748a95a44379d431")
        end
    elseif is_host("linux") then
        if is_arch("arm64", "aarch64") then
            add_urls("https://github.com/GaijinEntertainment/daScript/releases/download/$(version)/daslang-bundle-linux-arm64.zip", {version = function (version) return version:gsub("%+", ".") end})
            add_versions("v0.5.9+2.1", "23595d99a62279d4f2b9e50c7b47f9c46f6a7bd02dd2ce2a7e01e422021b1775")
        elseif is_arch("x86_64", "x64") then
            add_urls("https://github.com/GaijinEntertainment/daScript/releases/download/$(version)/daslang-bundle-linux-x86_64.zip", {version = function (version) return version:gsub("%+", ".") end})
            add_versions("v0.5.9+2.1", "7ca9c700d72097e14678aa9ae33bb15ebc98abf14c8d1fd9e9e89692d5513898")
        end
    end

    on_install("windows|!arm64", "linux", "macosx", function (package)
        os.cp("bin", package:installdir())
        os.cp("lib", package:installdir())
        os.cp("examples", package:installdir())
        os.cp("modules", package:installdir())
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        local name = "daslang"
        if package:is_plat("windows") then
            name = "daslang.exe"
        end
        os.touch("output.txt")
        local outfile = io.open("output.txt", "w")
        os.execv(name, {}, {try = true, stdout = outfile, stderr = os.nuldev()})
        outfile:close()
        local content = io.readfile("output.txt")
        print(content)
        assert(content:find("daslang version", 1, true))
    end)
