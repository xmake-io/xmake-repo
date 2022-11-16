package("bdd")
    set_description("The bdd package")

    add_urls("https://github.com/0warning0error/BuDDy.git")
    add_versions("2.4", "f44fa0f67802bf9f700711107100d40f7cf6eb6a")

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        -- TODO check includes and interfaces
        -- assert(package:has_cfuncs("foo", {includes = "foo.h"})
    end)
