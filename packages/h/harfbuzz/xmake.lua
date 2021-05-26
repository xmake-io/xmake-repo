package("harfbuzz")

    set_homepage("https://harfbuzz.github.io/")
    set_description("HarfBuzz is a text shaping library.")
    set_license("MIT")

    add_urls("https://github.com/harfbuzz/harfbuzz/archive/refs/tags/$(version).tar.gz",
             "https://github.com/harfbuzz/harfbuzz.git")
    add_versions("2.8.1", "b3f17394c5bccee456172b2b30ddec0bb87e9c5df38b4559a973d14ccd04509d")

    add_configs("icu", {description = "Use the ICU library.", default = false, type = "boolean"})

    add_deps("meson")
    if not is_plat("windows") then
        add_deps("glib", "cairo")
        add_deps("freetype", {configs = {png = false, woff2 = false, bzip2 = false, zlib = false}})
    end
    on_load("windows", "linux", "macosx", function (package)
        if package:config("icu") then
            package:add("deps", "icu4c")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        if package:config("icu") then
            table.insert(configs, "-Dicu=enabled")
        end
        if package:is_plat("windows") then
            table.insert(configs, "-Dfreetype=disabled")
        end
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("hb_buffer_add_utf8", {includes = "harfbuzz/hb.h"}))
    end)
