package("argus")
    set_homepage("https://argus-lib.com")
    set_description("Argus is a cross-platform modern feature-rich command-line argument parser for C")
    set_license("MIT")

    add_urls("https://github.com/lucocozz/Argus/archive/refs/tags/$(version).tar.gz",
             "https://github.com/lucocozz/Argus.git")

    add_versions("v0.1.0", "0e7780db65a06f72268a60336d8621ea17f704ec12c6d679c0ae86048ec6e8fc")

    add_deps("meson", "ninja")

    add_configs("regex", {description = "Enable regex validation support using PCRE2", default = false, type = "boolean"})


    on_load(function (package)
        if package:config("regex") then
            package:add("deps", "pcre2")
        end
    end)

    on_install(function (package)
        local configs = {"-Dregex=" .. (package:config("regex") and "true" or "false")}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("argus_init", {includes = "argus.h"}))
    end)
