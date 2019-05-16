package("skia")

    set_homepage("https://skia.org/")
    set_description("A complete 2D graphic library for drawing Text, Geometries, and Images.")

    set_urls("https://skia.googlesource.com/skia.git",
             "https://github.com/google/skia.git")

    add_versions("68046c", "68046cd7be837bd31bc8f0e821a2f82a02dda9cf")

    add_deps("python2", "ninja")

    add_links("skia")
    add_includedirs("include")
    add_includedirs("include/android")
    add_includedirs("include/atlastext")
    add_includedirs("include/c")
    add_includedirs("include/codec")
    add_includedirs("include/config")
    add_includedirs("include/core")
    add_includedirs("include/docs")
    add_includedirs("include/effects")
    add_includedirs("include/encode")
    add_includedirs("include/gpu")
    add_includedirs("include/pathops")
    add_includedirs("include/ports")
    add_includedirs("include/private")
    add_includedirs("include/svg")
    add_includedirs("include/third_party")
    add_includedirs("include/utils")
 
    -- @note windows: only can build for vs2017 or vs2015 update 3
    on_install("macosx", "linux", "windows", function (package)
        local pathes = os.getenv("PATH") or ""
        pathes = pathes .. path.envsep() .. path.join(os.curdir(), "depot_tools")
        pathes = pathes .. path.envsep() .. path.join(os.curdir(), "bin")
        local args = {is_official_build = false,
                      is_component_build = false,
                      is_debug = package:debug(),
                      skia_enable_gpu = true,
                      skia_enable_pdf = false,
                      skia_enable_nvpr = false,
                      skia_enable_tools = false,
                      skia_use_icu = false,
                      skia_use_sfntly = false,
                      skia_use_piex = false,
                      skia_use_freetype = false,
                      skia_use_harfbuzz = false,
                      skia_use_libheif = false,
                      skia_use_expat = false,
                      skia_use_libjpeg_turbo = false,
                      skia_use_libpng = false,
                      skia_use_libwebp = false,
                      skia_use_zlib = false}
        args.cc  = package:build_getenv("cc")
        args.cxx = package:build_getenv("cxx")
        local argstr = "" 
        for k, v in pairs(args) do
            if type(v) == "string" then
                argstr = argstr .. ' ' .. k .. '=\"' .. v .. "\""
            else
                argstr = argstr .. ' ' .. k .. '=' .. tostring(v)
            end
        end 
        os.vrun("python2 tools/git-sync-deps")
        os.vrun("bin/gn gen build --args='%s'", argstr:trim())
        os.vrun("ninja -C build")
        os.cp("include", package:installdir())
        os.cp("third_party/skcms/*.h", package:installdir("third_party/skcms"))
        if is_plat("windows") then
            os.cp("build/*.lib", package:installdir("lib"))
        else
            os.cp("build/*.a", package:installdir("lib"))
        end
    end)
  
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            static void test() {
                SkPaint paint;
                paint.setStyle(SkPaint::kFill_Style);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "core/SkPaint.h", defines = "DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN"}))
    end)
