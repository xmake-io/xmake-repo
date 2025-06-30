package("bass24")
    set_homepage("https://www.un4seen.com/")
    set_description("BASS is an audio library for use in software. It provides efficient sample, stream, MOD music, MO3 music, and recording functions.")
    
    if is_plat("windows") then
        if is_arch("arm64") then
            add_urls("https://www.un4seen.com/files/bass$(version)-arm64.zip", {version = function (version)
                return version:gsub("%.", "")
            end})
            add_versions("2.4", "57986e7868e524bd554ba31945e758fb973091bc74ee536859153a89f9b01617")
            add_resources("2.4", "bass_header", "https://www.un4seen.com/files/bass24.zip", "f9e74a672eb1ecee8e41dff0ec5bad24a2678181312c94b81988a718d7c29574")
        else
            add_urls("https://www.un4seen.com/files/bass$(version).zip", {version = function (version)
                return version:gsub("%.", "")
            end})
            add_versions("2.4", "f9e74a672eb1ecee8e41dff0ec5bad24a2678181312c94b81988a718d7c29574")
        end
    elseif is_plat("linux") then
        add_urls("https://www.un4seen.com/files/bass$(version)-linux.zip", {version = function (version)
            return version:gsub("%.", "")
        end})
        add_versions("2.4", "fc9025bed66d9f3bb36635b2de7d564fc4396552ced012490094fbfdd10b4b7a")
    elseif is_plat("macosx") then
        add_urls("https://www.un4seen.com/files/bass$(version)-osx.zip", {version = function (version)
            return version:gsub("%.", "")
        end})
        add_versions("2.4", "9fbcb50e5d3c6bb666b921f4a1088d975603a276128a7ceab527ff401ee0f352")
    elseif is_plat("android") then
        add_urls("https://www.un4seen.com/files/bass$(version)-android.zip", {version = function (version)
            return version:gsub("%.", "")
        end})
        add_versions("2.4", "9fce1f66a2754963665c5fc55fdefcd0d62a078a2299ae061f9c5f1e209fdd9e")
    elseif is_plat("iphoneos") then
        add_urls("https://www.un4seen.com/files/bass$(version)-ios.zip", {version = function (version)
            return version:gsub("%.", "")
        end})
        add_versions("2.4", "78f0b372c94d0bef767dc8fd08689e42d41db63a386b1ae718ef6982ca278733")
    end

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    if is_plat("iphoneos") then
        add_includedirs("lib/bass.framework/Headers")
        add_linkdirs("lib/bass.framework")
        add_frameworkdirs("lib/bass.framework")
        add_frameworks("bass")
    end

    on_install("windows", function (package)
        if package:is_arch("arm64") then
            local headerdir = package:resourcedir("bass_header")
            os.cp(path.join(headerdir, "c", "bass.h"), package:installdir("include"))
            os.cp("arm64/bass.dll", package:installdir("bin"))
            os.cp("c/arm64/bass.lib", package:installdir("lib"))
        elseif package:is_arch("x64") then
            os.cp("c/bass.h", package:installdir("include"))
            os.cp("x64/bass.dll", package:installdir("bin"))
            os.cp("c/x64/bass.lib", package:installdir("lib"))
        else
            os.cp("c/bass.h", package:installdir("include"))
            os.cp("bass.dll", package:installdir("bin"))
            os.cp("c/bass.lib", package:installdir("lib"))
        end
    end)

    on_install("linux", function (package)
        os.cp("bass.h", package:installdir("include"))
        if package:is_arch("x86_64") then
            os.cp("libs/x86_64/libbass.so", package:installdir("lib"))
        elseif package:is_arch("x86") then
            os.cp("libs/x86/libbass.so", package:installdir("lib"))
        elseif package:is_arch("arm64.*") then
            os.cp("libs/aarch64/libbass.so", package:installdir("lib"))
        else
            os.cp("libs/armhf/libbass.so", package:installdir("lib"))
        end
    end)

    on_install("macosx", function (package)
        os.cp("bass.h", package:installdir("include"))
        os.cp("libbass.dylib", package:installdir("lib"))
    end)

    on_install("android", function (package)
        os.cp("c/bass.h", package:installdir("include"))
        if package:is_arch("arm64.*") then
            os.cp("libs/arm64-v8a/libbass.so", package:installdir("lib"))
        elseif package:is_arch("arm.*") then
            os.cp("libs/armeabi-v7a/libbass.so", package:installdir("lib"))
        elseif package:is_arch("x86") then
            os.cp("libs/x86/libbass.so", package:installdir("lib"))
        else
            os.cp("libs/x86_64/libbass.so", package:installdir("lib"))
        end
    end)

    on_install("iphoneos", function (package)
        if package:is_arch("arm.*") then
            os.cp("bass.xcframework/ios-arm64_armv7_armv7s/bass.framework", package:installdir("lib"))
        else
            os.cp("bass.xcframework/ios-arm64_i386_x86_64-simulator/bass.framework", package:installdir("lib"))
        end
        os.cp("bass.h", package:installdir("lib/bass.framework/Headers"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("BASS_Init", {includes = "bass.h"}))
    end)
