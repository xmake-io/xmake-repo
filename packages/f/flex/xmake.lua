package("flex")

    set_kind("binary")
    set_homepage("https://github.com/westes/flex/")
    set_license("BSD-2-Clause")

    if not is_plat("windows") then
        add_urls("https://github.com/westes/flex/releases/download/v$(version)/flex-$(version).tar.gz")
    end

    add_versions("2.6.4", "e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995")

    if is_plat("windows") then
        add_deps("winflexbison")
    elseif is_plat("linux") then
        add_deps("m4")
    end

    on_load("macosx", "linux", function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("windows", function (package)
        -- handled by winflexbison
    end)

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        os.vrun("flex -h")
    end)
