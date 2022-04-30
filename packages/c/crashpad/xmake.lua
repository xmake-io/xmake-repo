package("crashpad")
    set_homepage("https://chromium.googlesource.com/crashpad/crashpad/+/refs/heads/main/README.md")
    set_description("Crashpad is a crash-reporting system.")

    if is_host("windows") then
    
        local map = {
            ["2021.8.1"] = "stable",
            ["2022.4.16"] = "latest"
        }
    
        function map_version(version)
            return map[tostring(version)]
        end
    
        if is_arch("x64", "x86_64") then
            set_urls("http://get.backtrace.io/crashpad/builds/crashpad-release-x86-64-$(version).zip", {version = map_version})
            add_versions("2021.8.1", "b3facf8a802dfd12daf4d9fba416f4d4b5df0ae544afa14080662fa978aa18cb")
            add_versions("2022.4.16", "7705073dfff89c376303cacea3a6f8c63322f77566ad5cdbe37060cf3cef9f8b")
        else
            set_urls("http://get.backtrace.io/crashpad/builds/crashpad-release-x86-$(version).zip", {version = map_version})
            add_versions("2021.8.1", "699fdf741f39da1c68069820ce891b6eb8b48ef29ab399fc1bcf210b67ff8547")
            add_versions("2022.4.16", "c3bffb64d1087198946739dfb30d24b2355e49ddfe90d8e2a75ed373ed6e3377")
        end
    end

    add_includedirs("include", "include/mini_chromium")

    on_install("windows", function (package)
        os.cp("include/*", package:installdir("include"))
        os.cp("bin/crashpad_handler.exe", package:installdir("bin"))
        if package:config("shared") then
            os.cp("lib_md/*", package:installdir("lib"))
        else
            os.cp("lib_mt/*", package:installdir("lib"))
        end
     end)
