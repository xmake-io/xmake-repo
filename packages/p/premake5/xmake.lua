package("premake5")
    set_kind("binary")
    set_homepage("https://premake.github.io/")
    set_description("Premake")

    set_urls("https://github.com/premake/premake-core.git")
    add_versions("2022.06.21", "1c22240cc86cc3a12075cc0fc8b07ab209f99dd3")
    
    if is_plat("linux") and linuxos.name() == "fedora" then 
        add_deps("libuuid")
    end

    on_install("@linux", "@macosx", "@windows", function (package)
        local configs = {"-f", "Bootstrap.mak"}
        table.insert(configs, package:plat())
        if package:is_plat("linux", "macosx") then
            local cflags = {}
            local ldflags = {}
            local dep = package:dep("libuuid")
            if dep then 
                local depinfo = dep:fetch()
                for _, includedir in ipairs(depinfo.includedirs or depinfo.sysincludedirs) do 
                    table.insert(cflags, "-I" .. includedir)
                end
                for _, linkdir in ipairs(depinfo.linkdirs) do 
                    table.insert(ldflags, "-L" .. linkdir)
                end
            end
            if #cflags > 0 then 
                table.insert(configs, "EXTRA_CFLAGS=" .. table.concat(cflags, " ")) 
                table.insert(configs, "EXTRA_CXXFLAGS=" .. table.concat(cflags, " "))
            end
            if #ldflags > 0 then
                table.insert(configs, "EXTRA_LDFLAGS=" .. table.concat(ldflags, " "))
            end
            import("package.tools.make").build(package, configs)
        else
            import("package.tools.nmake").build(package, configs)
        end
        os.mv("bin/release/premake5" .. (package:is_plat("windows") and ".exe" or ""), package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("premake5 --version")
    end)
