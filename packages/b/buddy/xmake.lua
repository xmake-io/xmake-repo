package("buddy")
    set_homepage("https://github.com/xmake-mirror/Buddy")
    set_description("Binary Decision Diagrams")

    add_urls("https://github.com/xmake-mirror/Buddy/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-mirror/Buddy.git")
    add_versions("2.4", "01f7fb04f389c6ba89ef759ea903a217acdaba5c5f7c5d137eb1e2327cb60675")

    on_install("linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("bdd_init", {includes = "bdd.h"}))
    end)
