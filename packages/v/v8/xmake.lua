package("v8")
    set_homepage("https://chromium.googlesource.com/v8/v8.git")
    set_description("V8 JavaScript Engine")

    add_urls("https://github.com/v8/v8.git")
    add_versions("10.0.58", "d75903764c8547b6fc35c7a3fe4991320be03135")

    add_deps("depot_tools")

    on_install(function (package)
        os.cd("v8")
        os.vrun("gclient sync -v")
        os.vrunv("python", {"./tools/dev/gm.py", "x64.release"})
--        import("package.tools.gn").build(package, args, {buildir = "out"})
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("V8::Initialize", {includes = "v8.h"}))
    end)
