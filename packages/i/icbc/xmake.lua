package("icbc")

    set_homepage("https://github.com/castano/icbc")
    set_description("A High Quality SIMD BC1 Encoder")
    set_license("MIT")
    
    add_urls("https://github.com/castano/icbc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/castano/icbc.git")
    add_versions("1.05", "51eba57870c018c8ccd673aab3c58fd5576fadb1c149c22c3fdacf42be197bfd")

    add_patches("1.05", path.join(os.scriptdir(), "patches", "1.05", "cleanup.patch"), "4704acc207940ec43c1b3bd7031ee05109fae61c0e044b0a71c899ed4612861d")

    on_install("windows", "macosx", "linux", function (package)
        io.writefile("icbc.cpp", [[
            #define ICBC_IMPLEMENTATION
            #include "icbc.h"
            #define IC_PFOR_IMPLEMENTATION
            #include "ic_pfor.h"
        ]])
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("icbc")
                set_kind("static")
                set_languages("cxx11")
                add_files("icbc.cpp")
                add_headerfiles("icbc.h", "ic_pfor.h")
                if is_plat("windows") then
                    add_cxxflags("/arch:AVX512")
                else
                    add_cxxflags("-march=native")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("icbc::Quality", {configs = {languages = "c++11"}, includes = "icbc.h"}))
    end)
