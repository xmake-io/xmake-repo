package("flex")
    set_kind("library", {headeronly = true})
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

    on_load("macosx", "linux", "bsd", "windows", "@msys", function (package)
        if package:is_plat("windows") then
            package:add("deps", "winflexbison", {private = true})
        elseif package:is_plat("linux") then
            package:add("deps", "m4")
        end

        if is_subhost("msys") and xmake:version():ge("2.9.7") then
            package:add("deps", "pacman::flex", {private = true, configs = {msystem = "msys"}})
        end

        if not package:is_cross() then
            package:addenv("PATH", "bin")
        end
        -- https://github.com/Seifert69/DikuMUD3/issues/70#issuecomment-1100932157
        -- Don't link libfl.so
        package:add("links", "")
    end)

    on_install("@msys", function (package)
        -- https://github.com/msys2/MSYS2-packages/issues/1911
        if package:is_library() then
            local msys_dir = os.getenv("MINGW_PREFIX")
            local header = path.join(path.directory(msys_dir), "usr/include/FlexLexer.h")
            os.vcp(header, package:installdir("include"))
        end
    end)

    on_install("windows", function (package)
        os.cp(path.join(package:dep("winflexbison"):installdir(), "*"), package:installdir())
        os.rm(path.join(package:installdir(), "bin", "bison.exe"))
    end)

    on_install("macosx", "linux", "bsd", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("flex -h")
        end
        if package:is_library() then
            assert(package:has_cxxincludes("FlexLexer.h"))
        end
    end)
