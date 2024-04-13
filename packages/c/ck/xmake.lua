package("ck")
    set_homepage("http://concurrencykit.org/")
    set_description("Concurrency primitives, safe memory reclamation mechanisms and non-blocking (including lock-free) data structures designed to aid in the research, design and implementation of high performance concurrent systems developed in C99+.")

    add_urls("https://github.com/concurrencykit/ck/archive/refs/tags/$(version).tar.gz",
             "https://github.com/concurrencykit/ck.git")
    add_versions("0.7.2", "568ebe0bc1988a23843fce6426602e555b7840bf6714edcdf0ed530214977f1b")
    add_versions("0.7.1", "97d2a21d5326ef79b4668be2e6eda6284ee77a64c0981b35fd9695c736c3d4ac")

    on_install("macosx", "linux", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--disable-static")
        end
        local cxflags
        if package:is_plat("linux") and package:config("pic") ~= false then
            cxflags = "-fpic"
        end
        import("package.tools.autoconf").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ck_barrier_combining_init", {includes = "ck_barrier.h"}))
    end)
