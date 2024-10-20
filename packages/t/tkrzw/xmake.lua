package("tkrzw")
    set_homepage("https://dbmx.net/tkrzw/")
    set_description("Tkrzw: a set of implementations of DBM")
    set_license("Apache-2.0")

    set_urls("https://github.com/estraier/tkrzw.git")

    add_versions("2024-06-04", "409a57bf7507a4079d0519bc4a023da8ab79e132")

    on_install("macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("tkrzw::ParseCommandArguments", {includes = "tkrzw_cmd_util.h"}))
    end)
