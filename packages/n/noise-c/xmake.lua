package("noise-c")
    set_homepage("https://github.com/rweather/noise-c")
    set_description("Noise-C, a plain C implementation of the Noise protocol")
    set_license("MIT")

    add_urls("https://github.com/rweather/noise-c.git")
    add_versions("2021.04.09", "9379e580a14c0374a57d826a49ba53b7440c80bc")

    add_deps("autoconf", "automake", "bison", "flex")

    on_install("linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:is_plat("linux") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("noise_handshakestate_set_prologue", {includes = "noise/protocol.h"}))
    end)
