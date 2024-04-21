package("md4c")
    set_homepage("https://github.com/mity/md4c")
    set_description("C Markdown parser. Fast. SAX-like interface. Compliant to CommonMark specification.")
    set_license("MIT")

    add_urls("https://github.com/mity/md4c.git")
    add_versions("2024.02.25", "481fbfbdf72daab2912380d62bb5f2187d438408")

    add_deps("cmake")

    add_links("md4c-html", "md4c")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("md_html", {includes = "md4c-html.h"}))
        if not package:is_cross() then
            os.exec("md2html --version")
        end
    end)
