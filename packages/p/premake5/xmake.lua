package("premake5")
    set_kind("binary")
    set_homepage("https://premake.github.io/")
    set_description("Premake")

    set_urls("https://github.com/premake/premake-core.git")
    add_versions("2022.06.21", "1c22240cc86cc3a12075cc0fc8b07ab209f99dd3")
    
    if is_plat("linux") and linuxos.name() == "fedora" then 
        add_deps("libuuid")
        add_patches("2022.06.21", path.join(os.scriptdir(), "patches", "2022.06.21", "make.patch"), "e27ec6aeccbf70b0b84d9d708d5a66aa4d0b4e86e519e7838555e67359f6ed17")
    end

    on_install("@linux", "@macosx", "@windows", function (package)
        local configs = {"-f", "Bootstrap.mak", package:plat()}
        if package:is_plat("linux", "macosx") then
            if linuxos.name() == "fedora" then 
                local flags = {}
                local depinfo = package:dep("libuuid"):fetch()
                for _, includedir in ipairs(depinfo.includedirs or depinfo.sysincludedirs) do 
                    table.insert(flags, "-I" .. includedir)
                end
                for _, linkdir in ipairs(depinfo.linkdirs) do 
                    table.insert(flags, "-L" .. linkdir)
                end
                local extrainfo = table.concat(flags, " ")
                io.replace("Bootstrap.mak", "-luuid", extrainfo .. " -luuid")
                io.replace("Bootstrap.mak", "$(MAKE) -C build/bootstrap -j`getconf _NPROCESSORS_ONLN` config=$(CONFIG)", "", {plain = true})
                import("package.tools.make").build(package, configs)
                io.replace("build/bootstrap/Premake5.make", "INCLUDES +=", "INCLUDES += " .. extrainfo)
                print(io.readfile("build/bootstrap/Premake5.make"))
                import("package.tools.make").build(package, {"-C", "build/bootstrap", "-j`getconf _NPROCESSORS_ONLN`", "configs=release"})
            else
                import("package.tools.make").build(package, configs)
            end
        else
            import("package.tools.nmake").build(package, configs)
        end
        os.mv("bin/release/premake5" .. (package:is_plat("windows") and ".exe" or ""), package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("premake5 --version")
    end)
