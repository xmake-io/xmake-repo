package("yoga")
    set_homepage("https://yogalayout.com/")
    set_description("Yoga is a cross-platform layout engine which implements Flexbox. Follow https://twitter.com/yogalayout for updates.")
    set_license("MIT")

    add_urls("https://github.com/facebook/yoga/archive/refs/tags/$(version).tar.gz",
             "https://github.com/facebook/yoga.git")

    add_versions("v3.0.0", "da4739061315fd5b6442e0658c2541db24ded359f41525359d5e61edb2f45297")
    add_versions("v2.0.1", "4c80663b557027cdaa6a836cc087d735bb149b8ff27cbe8442fc5e09cec5ed92")

    add_configs("shared", {description = "Build shared binaries", default = false, type = "boolean", readonly = true})

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "add_subdirectory(tests)", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("YGNodeNew", {includes = "yoga/Yoga.h"}))
    end)
