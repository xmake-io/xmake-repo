package("flex")

    set_kind("binary")
    set_homepage("https://github.com/westes/flex/")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/westes/flex/releases/download/v$(version)/flex-$(version).tar.gz")
    add_versions("2.6.4", "e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995")

    if is_plat("linux") then
        add_deps("m4")
    end

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        os.vrun("flex -h")
    end)
