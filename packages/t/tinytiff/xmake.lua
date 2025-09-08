package("tinytiff")
    set_homepage("http://jkriege2.github.io/TinyTIFF")
    set_description("lightweight TIFF reader/writer library (C/C++)")
    set_license("LGPL-3.0")

    add_urls("https://github.com/jkriege2/TinyTIFF/archive/refs/tags/$(version).tar.gz", {
        version = function (version)
            return version:gsub("%+", ".")
        end
    })
    add_urls("https://github.com/jkriege2/TinyTIFF.git", {alias = "git"})

    add_versions("4.0.1+0", "6272640f308345c3eb21a3d2575eb07ad5780f32bca674f06e00df3bdf0c595c")

    add_versions("git:4.0.1+0", "4.0.1.0")

    add_deps("cmake")

    on_install("!bsd", function (package)
        if not package:config("shared") then
            package:add("defines", "TINYTIFF_STATIC_DEFINE")
        end

        local configs = {"-DTinyTIFF_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("TinyTIFFReader_open", {includes = "tinytiffreader.h"}))
    end)
