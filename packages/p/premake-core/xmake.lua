package("premake-core")
    set_homepage("https://premake.github.io/")
    set_description("Premake")

    set_urls("")
    set_urls("https://github.com/premake/premake-core/archive/refs/tags/$(version).zip", 
             "https://github.com/premake/premake-core.git")
    
    add_versions("v5.0.0-beta1", "f4d1be74c514f39f2743698d66da92814aa120ccca9b1f0b2a8c63d8fbb57090")

    on_load("linux", "macosx", "windows", function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("linux", "macosx", "windows", function (package)
        local configs = {"-f", "Bootstrap.mak"}
        table.insert(configs, package:plat())
        if package:is_plat("linux", "macosx") then
            import("package.tools.make").build(package, configs)
        else
            import("package.tools.nmake").build(package, configs)
        end
        os.mv("bin/release/premake5" .. (package:is_plat("windows") and ".exe" or ""), package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("premake5 --version")
    end)
