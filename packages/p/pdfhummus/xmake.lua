package("pdfhummus")
    set_homepage("https://www.pdfhummus.com/")
    set_description("High performance library for creating, modiyfing and parsing PDF files in C++ ")
    set_license("Apache-2.0")

    add_urls("https://github.com/galkahana/PDF-Writer/archive/refs/tags/$(version).tar.gz",
             "https://github.com/galkahana/PDF-Writer.git")
    add_versions("4.1", "0C0D860B0ECEA928709B9E4642FA21926EB2F626F702699C3B87AFA2965B4857")
    add_patches("4.1", path.join(os.scriptdir(), "patches", "4.1", "cmake.patch"), "5919e990ca7277e8bc0f7af44a196c108689b5767cb24ee2eb98a7a29c52b33d")

    add_deps("cmake")
    add_deps("zlib")
    add_deps("freetype")

    add_configs("libtiff", {description = "Supporting tiff image", default = true, type = "boolean"})
    add_configs("libjpeg", {description = "Support DCT encoding", default = true, type = "boolean"})
    add_configs("libpng", {description = "Support png image", default = true, type = "boolean"})

    on_load(function (package)
        local function add_dep(conf, pkg)
            if package:config(conf) then
                package:add("deps", pkg or conf)
            end
        end
        add_dep("libtiff")
        add_dep("libpng")
        add_dep("libjpeg")
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DUSE_BUNDLED=FALSE")

        import("package.tools.cmake").install(package, configs)
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
