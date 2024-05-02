package("cmark")
    set_homepage("https://github.com/commonmark/cmark")
    set_description("CommonMark parsing and rendering library and program in C")

    add_urls("https://github.com/commonmark/cmark/archive/refs/tags/$(version).tar.gz",
             "https://github.com/commonmark/cmark.git")

    add_versions("0.31.0", "bbcb8f8c03b5af33fcfcf11a74e9499f20a9043200b8552f78a6e8ba76e04d11")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_TESTING=OFF")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cmark_markdown_to_html", {includes = "cmark.h"}))
    end)
