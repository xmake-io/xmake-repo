package("praxo-core")
    set_homepage("https://github.com/axisvela/praxo-core")
    set_description("Embeddable C agent runtime with policy, tools, streaming, and plugin hosts")
    set_license("MIT")

    add_urls("https://github.com/axisvela/praxo-core.git")
    add_versions("0.13.0", "da4cae049176c5f9d4d6912cdef3f69e1a10db41")

    on_install(function (package)
        local oldir = os.cd("language/c")
        import("package.tools.cmake").install(package, {"-DBUILD_TESTING=OFF"})
        os.cd(oldir)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("px_plugin_process_start_simple", {includes = "praxo_plugin_process.h"}))
    end)
