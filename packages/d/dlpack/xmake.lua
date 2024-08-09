package("dlpack")
    set_homepage("https://dmlc.github.io/dlpack/latest")
    set_description("common in-memory tensor structure ")
    set_license("Apache-2.0")

    add_urls("https://github.com/dmlc/dlpack/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dmlc/dlpack.git")

    add_versions("v0.8", "cf965c26a5430ba4cc53d61963f288edddcd77443aa4c85ce722aaf1e2f29513")

    add_configs("contrib", {description = "Build in progress unstable libraries", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if not package:config("contrib") then
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_MOCK=" .. (package:config("contrib") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("DLDevice", {includes = "dlpack/dlpack.h"}))
    end)
