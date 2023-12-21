package("flex")
    set_kind("binary")
    set_homepage("https://github.com/westes/flex/")
    set_license("BSD-2-Clause")

    if not is_plat("windows") then
        add_urls("https://github.com/westes/flex/releases/download/v$(version)/flex-$(version).tar.gz")
    end

    add_versions("2.6.4", "e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995")

    if is_plat("windows") then
        add_deps("winflexbison", {private = true})
    elseif is_plat("linux") then
        add_deps("m4")
    end

    on_load("macosx", "linux", "bsd", "windows", function (package)
        -- we always set it, because flex may be modified as library
        -- by add_deps("flex", {kind = "library"})
        package:addenv("PATH", "bin")
    end)

    on_install("windows", function (package)
        os.cp(path.join(package:dep("winflexbison"):installdir(), "*"), package:installdir())
        os.rm(path.join(package:installdir(), "bin", "bison.exe"))
    end)

    on_install("macosx", "linux", "bsd", "android", "iphoneos", "cross", function (package)
        import("package.tools.autoconf").install(package)
        if not package:is_binary() then
            package:add("links", "")
        end
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("flex -h")
        end
        if not package:is_binary() then
            assert(package:has_cxxincludes("FlexLexer.h"))
        end
    end)
