package("skia")

    set_homepage("https://skia.org/")
    set_description("A complete 2D graphic library for drawing Text, Geometries, and Images.")

    set_urls("https://skia.googlesource.com/skia.git",
             "https://github.com/google/skia.git")

    add_versions("68046c", "68046cd7be837bd31bc8f0e821a2f82a02dda9cf")

    add_deps("python2", "ninja")

    on_install("macosx", "linux", "windows", function (package)
        os.vrun("git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git")
        local pathes = os.getenv("PATH")
        os.addenv("PATH", path.join(os.curdir(), "depot_tools"))
        os.addenv("PATH", path.join(os.curdir(), "bin"))
        os.vrun("python2 tools/git-sync-deps")
        os.vrun("bin/gn gen build --args='is_official_build=true is_debug=false'")
        os.vrun("ninja -C build")
        os.setenv("PATH", pathes)
    end)

    on_test(function (package)
        import("lib.detect.check_cxsnippets")
        assert(check_cxsnippets({test = [[
            SkPaint paint;
            paint.setStyle(SkPaint::kFill_Style);
        ]]}, {configs = table.join(package:fetch(), {languages = "c++11"}), sourcekind = "cxx", includes = "core/SkPaint.h", defines = "DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN"}))
    end)
