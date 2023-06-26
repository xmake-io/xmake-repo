package("winflexbison")
    set_kind("binary")
    set_homepage("https://github.com/lexxmark/winflexbison")
    set_description("Win flex-bison is a windows port the Flex (the fast lexical analyser) and Bison (GNU parser generator)")
    set_license("GPL")

    set_urls("https://github.com/lexxmark/winflexbison/archive/refs/tags/$(version).tar.gz",
             "https://github.com/lexxmark/winflexbison.git")

    add_versions("v2.5.25", "8e1b71e037b524ba3f576babb0cf59182061df1f19cd86112f085a882560f60b")

    add_configs("flex", {description = "Enable flex", default = true, type = "boolean"})
    add_configs("bison", {description = "Enable bison", default = true, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        -- we always set it, because flex may be modified as library
        -- by add_deps("winflexbison", {kind = "library"})
        package:addenv("PATH", "bin")
    end)

    on_install("windows", function (package)
        local mode = (package:debug() and "Debug" or "Release")
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. mode)
        import("package.tools.cmake").build(package, configs)
        os.cp("custom_build_rules", package:installdir("bin"))
        os.cp(path.join("bin", mode, "*"), package:installdir("bin"))
        if package:config("flex") then
            os.cp("flex/src/FlexLexer.h", package:installdir("include"))
            os.cp(path.join(package:installdir("bin"), "win_flex.exe"), path.join(package:installdir("bin"), "flex.exe"))
        end
        if package:config("bison") then
            os.cp(path.join(package:installdir("bin"), "win_bison.exe"), path.join(package:installdir("bin"), "bison.exe"))
        end
    end)

    on_test(function (package)
        if package:config("bison") then
            os.vrun("bison.exe -h")
        end
        if package:config("flex") then
            os.vrun("flex.exe -h")
            if not package:is_binary() then
                assert(package:has_cxxincludes("FlexLexer.h"))
            end
        end
    end)
