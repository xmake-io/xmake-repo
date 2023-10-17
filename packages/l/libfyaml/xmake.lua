package("libfyaml")
    set_homepage("https://github.com/pantoniou/libfyaml")
    set_description("Fully feature complete YAML parser and emitter, supporting the latest YAML spec and passing the full YAML testsuite.")
    set_license("MIT")

    add_urls("https://github.com/pantoniou/libfyaml/archive/refs/tags/$(version).tar.gz",
             "https://github.com/pantoniou/libfyaml.git")

    add_versions("v0.9", "927306fc85c7566904751766d36178650766b34e59ce56882eaa5b60f791668c")

    add_deps("cmake")

    on_install("linux", "macosx", "bsd", "mingw", "msys", "android", "iphoneos", "cross", "wasm", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fy_library_version", {includes = "libfyaml.h"}))
    end)
