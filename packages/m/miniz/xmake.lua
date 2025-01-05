package("miniz")

    set_homepage("https://github.com/richgel999/miniz/")
    set_description("miniz: Single C source file zlib-replacement library")
    set_license("MIT")

    add_urls("https://github.com/richgel999/miniz/archive/refs/tags/$(version).tar.gz",
             "https://github.com/richgel999/miniz.git")
    add_versions("3.0.2", "c4b4c25a4eb81883448ff8924e6dba95c800094a198dc9ce66a292ac2ef8e018")

    on_install(function (package)
        configs = {}
        table.insert(configs, "-DBUILD_EXAMPLES=OFF")
        table.insert(configs, "-DBUILD_TESTS=OFF")
        table.insert(configs, "-DINSTALL_PROJECT=ON")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mz_compress", {includes = "miniz/miniz.h"}))
    end)
