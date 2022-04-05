package("cli")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/daniele77/cli")
    set_description("A library for interactive command line interfaces in modern C++")

    add_urls("https://github.com/daniele77/cli/archive/refs/tags/$(version).tar.gz",
             "https://github.com/daniele77/cli.git")
    add_versions("v2.0.0", "0fac3c9fab4527e6141f8fae92dabbd575b6cc71c42c3de76cb28725df68919a")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("cli::Cli", {configs = {languages = "c++17"}, includes = "cli/cli.h"}))
    end)
