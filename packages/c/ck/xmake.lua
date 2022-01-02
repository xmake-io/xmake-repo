package("ck")
    set_homepage("http://concurrencykit.org/")
    set_description("Concurrency primitives, safe memory reclamation mechanisms and non-blocking (including lock-free) data structures designed to aid in the research, design and implementation of high performance concurrent systems developed in C99+.")

    add_urls("https://github.com/concurrencykit/ck/archive/refs/tags/$(version).tar.gz",
             "https://github.com/concurrencykit/ck.git")
    add_versions("0.7.1", "97d2a21d5326ef79b4668be2e6eda6284ee77a64c0981b35fd9695c736c3d4ac")

    on_install("macosx", "linux", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--disable-static")
        end

        import("package.tools.autoconf").install(package, configs, {cxflags = "-fpic"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ck_barrier_combining_init", {includes = "ck_barrier.h"}))
    end)
