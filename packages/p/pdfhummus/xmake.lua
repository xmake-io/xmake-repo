-- TODO: optional compiling for tiff etc.

package("pdfhummus")
    set_homepage("https://www.pdfhummus.com/")
    set_description("High performance library for creating, modiyfing and parsing PDF files in C++ ")
    set_license("Apache-2.0")

    add_urls("https://github.com/galkahana/PDF-Write/archive/refs/tags/$(version).tar.gz",
             "https://github.com/galkahana/PDF-Write.git")
    add_versions("4.1", "0C0D860B0ECEA928709B9E4642FA21926EB2F626F702699C3B87AFA2965B4857")
    
    add_deps("cmake")
    add_deps("zlib")
    add_deps("freetype")
    add_deps("libtiff")
    add_deps("libpng")
    add_deps("libjpeg-turbo")

    on_install(function (package)
        local configs = {"-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release")}
        import("package.tools.cmake").install(package, configs)
        if not package:config("shared") then 
            os.rm(package:installdir("bin/*.dll"))
        end
    end)

    on_test(function (package)
        assert(package:has_cincludes("PDFWriter.h"))
    end)