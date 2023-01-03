package("pdfhummus")
    set_homepage("https://www.pdfhummus.com/")
    set_description("High performance library for creating, modiyfing and parsing PDF files in C++ ")
    set_license("Apache-2.0")

    add_urls("https://github.com/galkahana/PDF-Writer/archive/refs/tags/$(version).tar.gz",
             "https://github.com/galkahana/PDF-Writer.git")
    add_versions("4.1", "0C0D860B0ECEA928709B9E4642FA21926EB2F626F702699C3B87AFA2965B4857")
    add_patches("4.1", path.join(os.scriptdir(), "patches", "4.1", "cmake.patch"), "3b4dccebdd0a63186a86c2428f250e74221a824fd19ff616aa3db846119d3209")

    add_deps("cmake")
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

    on_install("linux", "macosx", function (package)
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
