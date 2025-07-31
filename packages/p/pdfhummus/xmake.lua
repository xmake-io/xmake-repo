package("pdfhummus")
    set_homepage("https://www.pdfhummus.com/")
    set_description("High performance library for creating, modiyfing and parsing PDF files in C++ ")
    set_license("Apache-2.0")

    add_urls("https://github.com/galkahana/PDF-Writer/archive/refs/tags/$(version).tar.gz",
             "https://github.com/galkahana/PDF-Writer/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/galkahana/PDF-Writer.git")
    add_versions("v4.7.0", "936c1ed887c5fd23da8cd9ff23c1bfa58545f60f66af8ff893024eda5dda1b98")
    add_versions("v4.6.8", "129706e0336e00deb6b2e80c4e92e1b30e3504ae9f8d5e5225b512fbd17a991a")
    add_versions("v4.6.7", "735c65d4685c5156f0876635f3bc1565700d0f648fbb1f384e46d186796c8bae")
    add_versions("v4.6.6", "8343820313e553052df68c75fe2bf35353da2719106e81eb2a8b026ff96c7d7c")
    add_versions("v4.6.4", "93b5f1dc88fd67fdebde409e927e828dfbae02efa44936e89728622411c6a047")
    add_versions("v4.6.3", "3b5d9ba4b49d0380678e8172f27cdb8eda196ea448e7f1cdd79620066d082ab9")
    add_versions("v4.6.2", "0a36815ccc9d207028567f90039785c824b211169ba5da68de84d0c15455ab62")
    add_versions("v4.6.1", "6e95fcb26ec679fa12ce6638d35a591e80960b35956a142d9a80b9a8c80ca824")
    add_versions("v4.5.10", "c185707d0ec87da390a1c458a191327b82404184f9ef57d4680831f894b01d84")
    add_versions("v4.5.9", "a875e3466227e99191a665240503842865967fe5c0a450190a5a967a29be0d14")
    add_versions("v4.5.8", "b19b4853774551d34187087aaafa89fcba69215acbb4747dbdf0025a3f780b89")
    add_versions("v4.5.7", "191f39dcc61522c50a3bee96b3f0ccef208c27968fd22d5ab474acb512c24d10")
    add_versions("v4.5.6", "72a4f3fbbc39d4f169911454e9977ef8dd882bd5c0a305bd3133347903cff705")
    add_versions("4.1", "0c0d860b0ecea928709b9e4642fa21926eb2f626f702699c3b87afa2965b4857")

    add_deps("freetype", "zlib", "libaesgm")

    add_configs("libtiff", {description = "Supporting tiff image", default = false, type = "boolean"})
    add_configs("libjpeg", {description = "Support DCT encoding", default = false, type = "boolean"})
    add_configs("libpng", {description = "Support png image", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("m")
    end

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
