package("praxo-core")
    set_homepage("https://github.com/axisvela/praxo-core")
    set_description("Embeddable C agent runtime with policy, tools, streaming, and plugin hosts")
    set_license("MIT")

    add_urls("https://github.com/axisvela/praxo-core/archive/refs/tags/c/v$(version).tar.gz")
    add_versions("0.13.0", "ec14a35a635da7569ccc3d3a986cfbcd93d210c2a8e1c74f078654b18c92b136")

    add_deps("cmake")

    on_install(function (package)
        local oldir = os.cd("language/c")
        import("package.tools.cmake").install(package, {"-DBUILD_TESTING=OFF"})
        os.cd(oldir)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("px_plugin_process_start_simple", {includes = "praxo_plugin_process.h"}))
    end)
