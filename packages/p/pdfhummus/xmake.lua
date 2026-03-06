package("pdfhummus")
    set_homepage("https://www.pdfhummus.com/")
    set_description("High performance library for creating, modiyfing and parsing PDF files in C++ ")
    set_license("Apache-2.0")

    add_urls("https://github.com/galkahana/PDF-Writer/archive/refs/tags/$(version).tar.gz",
             "https://github.com/galkahana/PDF-Writer.git")
    add_versions("v4.8.1", "9b96c040cb04ca116450c0ed53462b6aa66b299c555401bf498b14db847f0898")
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

    add_deps("freetype", "zlib", "libaesgm")

    add_configs("libtiff", {description = "Supporting tiff image", default = false, type = "boolean"})
    add_configs("libjpeg", {description = "Support DCT encoding", default = false, type = "boolean"})
    add_configs("libpng", {description = "Support png image", default = false, type = "boolean"})
    add_configs("openssl3", {description = "Support PDF2.0 encryption", default = true, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("m")
    end

    on_load(function (package)
        for _, dep in ipairs({"libtiff", "libpng", "libjpeg", "openssl3"}) do
            if package:config(dep) then
                package:add("deps", dep)
            end
        end
    end)
    on_install("linux", "windows", "mingw", "macosx", function (package)
        local configs = {"-DUSE_BUNDLED=FALSE"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DPDFHUMMUS_NO_DCT=" .. (package:config("libjpeg") and "OFF" or "ON"))
        table.insert(configs, "-DPDFHUMMUS_NO_TIFF=" .. (package:config("libtiff") and "OFF" or "ON"))
        table.insert(configs, "-DPDFHUMMUS_NO_PNG=" .. (package:config("libpng") and "OFF" or "ON"))
        table.insert(configs, "-DPDFHUMMUS_NO_OPENSSL=" .. (package:config("openssl3") and "OFF" or "ON"))
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
