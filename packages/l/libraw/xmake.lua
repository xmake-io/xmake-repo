package("libraw")
    set_homepage("http://www.libraw.org")
    set_description("LibRaw is a library for reading RAW files from digital cameras.")

    add_urls("https://github.com/LibRaw/LibRaw/archive/$(version).tar.gz", {alias = "binary"})
    add_urls("https://github.com/LibRaw/LibRaw.git", {alias = "git"})
    
    add_versions("binary:0.19.5", "9a2a40418e4fb0ab908f6d384ff6f9075f4431f8e3d79a0e44e5a6ea9e75abdc")
    add_versions("git:0.19.5", "0.19.5")

    on_install(function(package)
        os.mkdir("include")
        os.cp("libraw", "include")
        io.writefile("xmake.lua", [[
            target("libraw")
                set_kind("shared")
                add_defines("LIBRAW_BUILDLIB")
                if is_plat("windows") then
                    add_defines("WIN32")
                end
                add_includedirs("include", {public = true})
                add_headerfiles("include(/libraw/*.h)")
                add_includedirs("")
                add_files("src/libraw_cxx.cpp", 
                    "src/libraw_datastream.cpp", 
                    "src/libraw_c_api.cpp")
                add_files("internal/dcraw_common.cpp", 
                    "internal/dcraw_fileio.cpp", 
                    "internal/demosaic_packs.cpp")        
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function(package)
        local defines = is_plat("windows") and {"WIN32"} or {}
        assert(package:has_cfuncs("libraw_version", {configs = {defines = defines}, includes = {"libraw/libraw.h"}, }))
    end)