package("dyncall")
    set_homepage("https://www.dyncall.org")
    set_description("dyncall library provides a clean and portable C interface to dynamically issue calls to foreign code using small call kernels written in assembly.")

    add_urls("https://www.dyncall.org/r$(version)/dyncall-$(version).tar.gz")

    add_versions("1.4", "14437dbbef3b6dc92483f6507eaf825ab97964a89eecae8cb347a6bec9c32aae")

    add_configs("shared", {description = "only has static library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")

    on_install("!wasm", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dcNewCallVM", {includes = "dyncall.h"}))
    end)
