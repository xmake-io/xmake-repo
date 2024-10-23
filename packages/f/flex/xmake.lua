package("flex")
    set_kind("binary")
    set_homepage("https://github.com/westes/flex/")
    set_license("BSD-2-Clause")

    add_versions("2.6.4", "e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995")

    if on_source then
        on_source(function (package)
            if not package:is_plat("windows", "mingw", "msys") then
                package:add("urls", "https://github.com/westes/flex/releases/download/v$(version)/flex-$(version).tar.gz")
            end
        end)
    elseif not is_plat("windows", "mingw", "msys") then
        add_urls("https://github.com/westes/flex/releases/download/v$(version)/flex-$(version).tar.gz")
    end

    if is_subhost("msys") then
        add_deps("pacman::flex")
    end

    on_load("macosx", "linux", "bsd", "windows", function (package)
        if package:is_plat("windows") then
            package:add("deps", "winflexbison", {private = true})
        elseif package:is_plat("linux") then
            package:add("deps", "m4")
        end

        -- we always set it, because flex may be modified as library
        -- by add_deps("flex", {kind = "library"})
        package:addenv("PATH", "bin")
        if package:is_library() then
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_install("@msys", function (package)
    end)

    on_install("windows", function (package)
        os.cp(path.join(package:dep("winflexbison"):installdir(), "*"), package:installdir())
        os.rm(path.join(package:installdir(), "bin", "bison.exe"))
    end)

    on_install("macosx", "linux", "bsd", "android", "iphoneos", "cross", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("flex -h")
        end
        if package:is_library() then
            assert(package:has_cxxincludes("FlexLexer.h"))
        end
    end)
