package("melon")
    set_homepage("http://doc.melonc.io")
    set_description(" A generic cross-platform C library that includes many commonly used components and frameworks, and a new scripting language interpreter. It currently supports C99 and Aspect-Oriented Programming (AOP).")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Water-Melon/Melon.git")
    add_versions("2024.03.22", "7ddf1c66894f6449feb86b7b654b3a4bb8184c76")

    add_deps("autoconf", "automake", "libtool")

    on_install("!windows", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mln_aes_init", {includes = "mln_aes.h"}))
    end)
