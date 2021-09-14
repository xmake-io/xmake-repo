package("libbacktrace")

    set_homepage("https://github.com/ianlancetaylor/libbacktrace")
    set_description("A C library that may be linked into a C/C++ program to produce symbolic backtraces")

    add_urls("https://github.com/ianlancetaylor/libbacktrace.git")
    add_versions("v1.0", "d0f5e95a87a4d3e0a1ed6c069b5dae7cbab3ed2a")

    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf").install(package)
    end)
