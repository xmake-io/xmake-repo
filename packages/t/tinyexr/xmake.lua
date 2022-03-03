package("tinyexr")

    set_homepage("https://github.com/syoyo/tinyexr/")
    set_description("Tiny OpenEXR image loader/saver library")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/syoyo/tinyexr/archive/refs/tags/$(version).tar.gz",
             "https://github.com/syoyo/tinyexr.git")
    add_versions("v1.0.1", "4dbbd8c7d17597ad557518de5eb923bd02683d26d0de765f9224e8d57d121677")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake", "miniz")
    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("miniz")
            target("tinyexr")
                set_kind("static")
                set_languages("c++11")
                add_files("tinyexr.cc")
                add_headerfiles("tinyexr.h")
                add_packages("miniz")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("IsEXR", {includes = "tinyexr.h"}))
    end)
