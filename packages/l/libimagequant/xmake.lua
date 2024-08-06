package("libimagequant")

    set_homepage("https://pngquant.org/lib/")
    set_description("Small, portable C library for high-quality conversion of RGBA images to 8-bit indexed-color (palette) images.")
    set_license("GPL-3.0")

    add_urls("https://github.com/ImageOptim/libimagequant/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ImageOptim/libimagequant.git")
    add_versions("4.3.3", "c50a59003a4c4ce53c76314e62f1e86d86d882bc09addb13daa0faa9260b9614")
    add_versions("2.15.1", "3a9548f99be8c3b20a5d9407d0ca95bae8b0fb424a2735a87cb6cf3fdd028225")

    add_configs("sse", {description = "Use SSE.", default = true, type = "boolean"})

    on_install("windows", "macosx", "linux", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            option("sse")
                set_showmenu(true)
                add_defines("USE_SSE")
            target("imagequant")
                set_kind("$(kind)")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
                add_files("libimagequant.c", "blur.c", "mediancut.c", "mempool.c", "nearest.c", "pam.c", "kmeans.c")
                add_headerfiles("libimagequant.h")
                add_options("sse")
        ]])
        local configs = {}
        configs.kind = package:config("shared") and "shared" or "static"
        configs.sse = package:config("sse") and true or false
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("liq_attr_create", {includes = "libimagequant.h"}))
    end)
