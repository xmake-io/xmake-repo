package("pdfio")
    set_homepage("https://www.msweet.org/pdfio")
    set_description("PDFio is a simple C library for reading and writing PDF files.")
    set_license("Apache-2.0")

    add_urls("https://github.com/michaelrsweet/pdfio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/michaelrsweet/pdfio.git")

    add_versions("v1.3.0", "aae5b4850560869021f6af1700a0681f0d19299554f24abf890a1a78188ddf02")

    if is_plat("windows", "mingw") then
        add_syslinks("advapi32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    add_deps("zlib")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_requires("zlib")
            add_packages("zlib")
            add_rules("mode.debug", "mode.release")
            target("pdfio")
                set_kind("$(kind)")
                add_files("*.c|test*.c")
                add_headerfiles("pdfio.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
                if is_plat("windows", "mingw") then
                    add_syslinks("advapi32")
                elseif is_plat("linux", "bsd") then
                    add_syslinks("m")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pdfioArrayCreate", {includes = "pdfio.h"}))
    end)
