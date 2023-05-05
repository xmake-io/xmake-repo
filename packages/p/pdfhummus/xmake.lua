package("pdfhummus")
    set_homepage("https://www.pdfhummus.com/")
    set_description("High performance library for creating, modiyfing and parsing PDF files in C++ ")
    set_license("Apache-2.0")

    add_urls("https://github.com/galkahana/PDF-Writer/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/galkahana/PDF-Writer/archive/refs/tags/$(version).tar.gz",
             "https://github.com/galkahana/PDF-Writer.git")
    add_versions("4.1", "0c0d860b0ecea928709b9e4642fa21926eb2f626f702699c3b87afa2965b4857")
    add_versions("4.5.6", "72a4f3fbbc39d4f169911454e9977ef8dd882bd5c0a305bd3133347903cff705")

    add_deps("freetype", "zlib", "libaesgm")

    add_configs("libtiff", {description = "Supporting tiff image", default = false, type = "boolean"})
    add_configs("libjpeg", {description = "Support DCT encoding", default = false, type = "boolean"})
    add_configs("libpng", {description = "Support png image", default = false, type = "boolean"})

    on_load(function (package)
        for _, dep in ipairs({"libtiff", "libpng", "libjpeg"}) do
            if package:config(dep) then
                package:add("deps", dep)
            end
        end
    end)
    on_install("linux", "windows", "mingw", "macosx", function (package)
        io.writefile("xmake.lua", [[
            option("libtiff", {description = "Enable libtiff", default = false})
            option("libpng", {description = "Enable libpng", default = false})
            option("libjpeg", {description = "Enable libjpeg", default = false})
            add_rules("mode.debug", "mode.release")
            if has_config("libtiff") then
                add_requires("libtiff")
            end
            if has_config("libpng") then
                add_requires("libpng")
            end
            if has_config("libjpeg") then
                add_requires("libjpeg")
            end
            add_requires("freetype", "zlib", "libaesgm")
            target("pdfwriter")
                set_kind("$(kind)")
                add_files("PDFWriter/*.cpp")
                add_headerfiles("(PDFWriter/*.h)")
                add_packages("freetype")
                add_packages("libtiff", "libpng", "libjpeg")
                add_packages("libaesgm", "zlib")
                if has_package("libtiff") then
                    add_defines("_INCLUDE_TIFF_HEADER")
                    add_cxflags("-Wno-deprecated-declarations")
                else
                    add_defines("PDFHUMMUS_NO_TIFF=1")
                end
                if not has_package("libpng") then
                    add_defines("PDFHUMMUS_NO_PNG=1")
                end
                if not has_package("libjpeg") then
                    add_defines("PDFHUMMUS_NO_DCT=1")
                end
                -- port symbols for linker
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        for _, dep in ipairs({"libtiff", "libpng", "libjpeg"}) do
            if package:config(dep) then
                configs[dep] = true
            end
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "PDFWriter/PDFWriter.h"
            #include <iostream>
            using namespace std;
            using namespace PDFHummus;
            void test() {
                PDFWriter pdfWriter;
                pdfWriter.Reset();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
