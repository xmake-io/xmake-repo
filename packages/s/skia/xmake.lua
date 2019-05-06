package("skia")

    set_homepage("https://skia.org/")
    set_description("A complete 2D graphic library for drawing Text, Geometries, and Images.")

    set_urls("hhttps://skia.googlesource.com/skia.git",
             "https://github.com/google/skia.git")

    add_versions("2f3637", "2f3637bf2ed44ef75966786ab4c2974d17c9f649")

    add_deps("python", "ninja")

    on_install("macosx", "linux", "windows", function (package)
        os.vrun("python tools/git-sync-deps")
        os.vrun("bin/gn gen build --args='is_official_build=true is_debug=false'")
        os.vrun("ninja -C build")
    end)

    on_test(function (package)
        import("lib.detect.check_cxsnippets")
        assert(check_cxsnippets({test = [[
            SkPaint paint;
            paint.setStyle(SkPaint::kFill_Style);
        ]]}, {configs = table.join(package:fetch(), {languages = "c++11"}), sourcekind = "cxx", includes = "core/SkPaint.h", defines = "DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN"}))
    end)
