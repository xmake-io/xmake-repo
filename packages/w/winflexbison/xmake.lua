package("winflexbison")
    set_kind("binary")
    set_homepage("https://github.com/lexxmark/winflexbison")
    set_description("Win flex-bison is a windows port the Flex (the fast lexical analyser) and Bison (GNU parser generator)")
    set_license("GPL")

    set_urls("https://github.com/lexxmark/winflexbison/archive/refs/tags/$(version).tar.gz",
             "https://github.com/lexxmark/winflexbison.git")

    add_versions("v2.5.25", "8e1b71e037b524ba3f576babb0cf59182061df1f19cd86112f085a882560f60b")

    add_deps("cmake")

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("windows", function (package)
        local mode = (package:debug() and "Debug" or "Release")
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. mode)
        import("package.tools.cmake").build(package, configs)
        os.mv("custom_build_rules", package:installdir("bin"))
        os.mv("flex/src/FlexLexer.h", package:installdir("include"))
        os.mv(path.join("bin", mode, "*"), package:installdir("bin"))
        os.cp(path.join(package:installdir("bin"), "win_bison.exe"), path.join(package:installdir("bin"), "bison.exe"))
        os.cp(path.join(package:installdir("bin"), "win_flex.exe"), path.join(package:installdir("bin"), "flex.exe"))
    end)

    on_test(function (package)
        os.vrun("win_bison.exe -h")
        os.vrun("win_flex.exe -h")
    end)
